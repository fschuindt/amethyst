# Teller

The second piece of our umbrella is the `:teller` application. It's responsible for providing a GraphQL gateway to the [`:database`](database.html) application.

For a complete set of examples to the GraphQL API, check [API](api.html).

Or upload the `graphiql_workspace.json` file (at the root of the repository) to the [GraphiQL endpoint](http://localhost:7171/graphiql).

## API Authorization

My initial plan for authorization was to use [Guardian](https://github.com/ueberauth/guardian) and provide a JWT based system. But in a attempt to speed up the first deliverance, I've opted to use a weak token.

It's weak for a number of reasons: Lack of TTL, plain text storage, faulty randomness. All on top of a plain text HTTP connection.

But it may fit us for now. Improving it should be the next step.

That said, here's how to perform authorizations: [Authorization](api.html#authorization).

## API Level Errors

Check `Teller.ErrorMessages` for a complete set of GraphQL API leveled errors.
