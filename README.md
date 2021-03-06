# Amethyst
[![CircleCI](https://circleci.com/gh/fschuindt/amethyst/tree/master.svg?style=svg)](https://circleci.com/gh/fschuindt/amethyst/tree/master) [![codecov](https://codecov.io/gh/fschuindt/amethyst/branch/master/graph/badge.svg)](https://codecov.io/gh/fschuindt/amethyst)

Few notes first:

- *This application used to be online on a Digital Ocean Docker Machine. But since I got approved into the Stone Payments hiring process it's no longer online. It's no more needed.*

- *Check out the documentation iside the `doc` directory. It's richer than this README file.*

Amethyst is a persisted bank account service provider built as a corporate challenge proposed by the [Stone Payments](https://github.com/stone-payments) to me in order to evaluate my Elixir advancements and as a opportunity to me to study and implement new concepts.

By keeping a daily-based assets movements logbook it offers the user a wide range of options for reporting financial transactions over any period of time.

It's developed as a Elixir umbrella application, stores its data in a PostgreSQL database with the help of [Ecto](https://hexdocs.pm/ecto/Ecto.html), serves a [GraphQL API](https://graphql.org/) with [Absinthe](https://absinthe-graphql.org/) and used to run over a [Docker Machine](https://docs.docker.com/machine/overview/) droplet inside [Digital Ocean](https://www.digitalocean.com/).

![System Diagram](https://s15.postimg.cc/pgrsocgmz/amethyst_1.png)  
*This image shows the old IP address it used to run over.*

It also uses [Distillery](https://hexdocs.pm/distillery/) to set up a compiled BEAM release into production. So while running it lacks the Mix environment and act solely as [OTP Application](http://erlang.org/doc/man/application.html). That being said, there's no Elixir installed at the production environment, just BEAM and [ERTS](http://erlang.org/doc/apps/erts/index.html).

And that's why there's two `FROM` statements inside a single Dockerfile. It's a multi-stage build, which is a fairly common practice for compiling and releasing Mix applications into OTP ones.

A brief scheme for the production stack:

| Container    | Description                                                          |
|--------------|----------------------------------------------------------------------|
| **database** | Our PostgreSQL database.                                             |
| **docs**     | A [Lighttpd](https://www.lighttpd.net/) server with our ExDoc files. |
| **amethyst** | Our OTP environment.                                                 |

And we serve over:

|              | Endpoint                                                                 |
|--------------|--------------------------------------------------------------------------|
| GraphQL      | `localhost:7171`                                                       |
| *GraphiQL*   | [http://localhost:7171/graphiql](http://localhost:7171/graphiql)         |
| ExDoc        | [http://localhost](http://localhost)                                     |

Be sure to check the Ametyst ExDoc documentation page for in-depth insights on implementations and API usage guides. It also offers documentation for each umbrella application.

*All functions describe [Typespecs](https://hexdocs.pm/elixir/typespecs.html) for agreements with [Dialyzer](http://erlang.org/doc/man/dialyzer.html).*  
*Every module has its [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) counterpart, although automated analysis with [ExCoveralls](https://github.com/parroty/excoveralls) reports over 77%, in practical terms it can be considered 100%. Check the report [here](http://104.131.80.76/cover/excoveralls.html).*

Also, at production environment [Sentry](https://sentry.io/fschuindt/amethyst/) is being used to track runtime exceptions.

## How to access ExDoc pages (Documentation)

In this repository, there's a directory named `./doc/`, it contains our plain HTML ExDoc documentation pages. But for a better experience, you can simply run:

```
$ docker-compose up -d docs
```

Then access the page at [http://localhost/](http://localhost/). I strongly recommend you to read it.

If you want to use other port than `80`, simply change the `docs` port at the `docker-compose.yml` file.

**Some relevant pages:**
- [`:database` OTP Application](http://localhost/database.html)
- [`:teller` OTP Application](http://localhost/teller.html)
- [API Usage](http://localhost/api.html)

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

### Static Code Analisys

[Credo](https://github.com/rrrene/credo) can be used to give us a static analysis:
```
$ mix credo

Checking 67 source files (this might take a while) ...

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 1 second (0.02s to load, 1.0s running checks)
238 mods/funs, found no issues.
```

It's currently being performed during continuous integration with CircleCI.

## Containerized Setup

The current Amethyst Docker container lacks the Mix environment. So at the present time testing is restrict to the [Native Setup](#native-setup).

In order to setup Amethyst into Docker, we will release it. This guide covers it.

*Be sure to get into Amethyst directory.*

First, set your local `prod.env` file by:
```
$ cp prod.env.sample prod.env
```

Then, start Postgres:
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
$ docker-compose up -d amethyst
```

At this point you should be able to access: [http://localhost:7171/graphiql](http://localhost:7171/graphiql).

## License
This is a "study-only purpose" software developed by [fschuindt](https://github.com/fschuindt/).

It's available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
