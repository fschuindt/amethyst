# Amethyst

Amethyst is a persisted bank account service provider built as a corporate challenge proposed by the [Stone Payments](https://github.com/stone-payments) to me in order to evaluate my Elixir advancements and as a opportunity to me to study and implement new concepts.

By keeping a daily-based assets movements logbook it offers the user a wide range of options for reporting financial transactions over any period of time.

It's developed as a Elixir umbrella application, stores its data in a PostgreSQL database with the help of [Ecto](https://hexdocs.pm/ecto/Ecto.html), serves a [GraphQL API](https://graphql.org/) with [Absinthe](https://absinthe-graphql.org/) and runs over a [Docker Machine](https://docs.docker.com/machine/overview/) droplet inside [Digital Ocean](https://www.digitalocean.com/).

It also uses [Distillery](https://hexdocs.pm/distillery/) to set up a compiled BEAM release into production. So while running it lacks the Mix environment and act solely as [OTP Application](http://erlang.org/doc/man/application.html). That being said, there's no Elixir installed at the production environment, just BEAM and [ERTS](http://erlang.org/doc/apps/erts/index.html).

And that's why there's two `FROM` statements inside a single Dockerfile. Which is a fairly common practice for compiling and releasing Mix applications into OTP ones.

A brief scheme for the production stack:

| Container    | Description                                                          |
|--------------|----------------------------------------------------------------------|
| **database** | Our PostgreSQL database.                                             |
| **docs**     | A [Lighttpd](https://www.lighttpd.net/) server with our ExDoc files. |
| **amethyst** | Our OTP environment.                                                 |

And we serve over:

|              | Endpoint                                                                 |
|--------------|--------------------------------------------------------------------------|
| GraphQL      | `104.131.80.76:7171`                                                  |
| *GraphiQL*   | [http://104.131.80.76:7171/graphiql](http://104.131.80.76:7171/graphiql) |
| ExDoc        | [http://104.131.80.76](http://104.131.80.76)                             |

Be sure to check the [Ametyst ExDoc documentation](http://104.131.80.76) page for in-depth insights on implementations and API usage guides. It also offers documentation for each umbrella application.

*All functions describe [Typespecs](https://hexdocs.pm/elixir/typespecs.html) for agreements with [Dialyzer](http://erlang.org/doc/man/dialyzer.html).*  
*Every module has its [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) counterpart, although automated analysis with [ExCoveralls](https://github.com/parroty/excoveralls) reports over 77%, in practical terms it can be considered 100%. Check the report [here](http://104.131.80.76/cover/excoveralls.html).*

## Relevant Pages
- [`:database` OTP Application](http://104.131.80.76/database.html)
- [`:teller` OTP Application](http://104.131.80.76/teller.html)
- [API Usage](http://104.131.80.76/api.html)

## Native Setup

This guide will cover how to set Amethyst running locally on your native Mix environment using Docker for our Postgres container.

For a fully containerized set up, check [Containerized Setup](#containerized-setup).

*Be sure to get into Amethyst directory.*

First, let's set our session variables and `MIX_ENV` to `dev`:
```
$ eval $(cat dev.env)
```

Then start Postgres:
```
$ docker-compose up -d database
```

Perform Ecto migrations:
```
$ mix ecto.migrate
```

Start the application:
```
$ iex -S mix
```

At this point you should be able to access: [http://localhost:7171/graphiql](http://localhost:7171/graphiql).

### Testing

For testing I recommend setting up the test session variables with:
```
$ eval $(cat test.env)
```

Then performing tests (requires the `database` container to be up):
```
$ mix test
```

### Typespecs Static Analysis (Discrepancy Analyzer)

To run [Dialyzer](http://erlang.org/doc/man/dialyzer.html) you can simply run [Dialyxir](https://github.com/jeremyjh/dialyxir):

(It should run inside development environment)
```
$ eval $(cat dev.env)
```

```
$ mix dialyzer
```

## Containerized Setup

The current Amethyst Docker container lacks the Mix environment. So at the present time testing is restrict to the [Native Setup](#native-setup).

In order to setup Amethyst into Docker, we will release it. This guide covers it.

*Be sure to get into Amethyst directory.*

Start Postgres:
```
$ docker-compose up -d database
```

Build our Dockerfile:
```
$ docker-compose build amethyst
```

Run Ecto migrations:
```
$ docker-compose run --rm amethyst bin/amethyst migrate
```

Start the application:
```
$ docker-compose up amethyst
```

At this point you should be able to access: [http://localhost:7171/graphiql](http://localhost:7171/graphiql).

## License
This is a "study-only purpose" software developed by [fschuindt](https://github.com/fschuindt/).

It's available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
