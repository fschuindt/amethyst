defmodule Teller.Router do
  @moduledoc """
  The main/only Plug router.

  Servers the `Teller.GraphQL.Schema` as a GraphQL API with a
  GraphiQL endpoint.

  Note all connections comes through the `Teller.Authorize` Plug.
  """

  use Plug.Router
  use Plug.ErrorHandler
  use Sentry.Plug

  plug Teller.Authorize

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Poison

  plug :match
  plug :dispatch

  forward "/amethyst",
    to: Absinthe.Plug,
    init_opts: [schema: Teller.GraphQL.Schema]

  forward "/graphiql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [schema: Teller.GraphQL.Schema]

  match _ do
    send_resp(conn, 404, "")
  end
end
