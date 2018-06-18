defmodule Teller.Test.Support.GraphQuery do
  @moduledoc """
  A support module for testing the GraphQL API.

  Acts pretty much as a client.
  """

  use Plug.Test

  @typedoc """
  A common response to GraphQL queries.
  """
  @type response_t :: {:ok | :error, Plug.Conn.t(), map() | binary()}

  @doc """
  Queries the GraphQL API with a unauthorized request.

  The `query` argument should be a valid GraphQL query.
  """
  @spec connect(binary) :: response_t()
  def connect(query) do
    conn(:post, "/graphiql", body(query))
    |> Teller.Router.call([])
    |> respond()
  end

  @doc """
  Queries the GraphQL API with a authorized request.

  The `query` argument should be a valid GraphQL query.
  `id` and `token` should be the authorization credentials.
  """
  @spec connect(binary, integer, binary) :: response_t()
  def connect(query, id, token) do
    conn(:post, "/graphiql", body(query))
    |> put_req_header("account-id", Integer.to_string(id))
    |> put_req_header("api-token", token)
    |> Teller.Router.call([])
    |> respond()
  end

  @spec respond(Plug.Conn.t) :: response_t()
  defp respond(conn) do
    do_respond(conn, decode_response(conn))
  end

  @spec do_respond(Plug.Conn.t, map) :: response_t()

  defp do_respond(conn, %{"message" => message}) do
    {:error, conn, message}
  end

  defp do_respond(conn, response) do
    {:ok, conn, response}
  end

  @spec decode_response(Plug.Conn.t) :: map()
  defp decode_response(conn) do
    conn.resp_body
    |> Poison.decode!()
    |> get_attributes()
  end

  @spec get_attributes(map) :: map()

  defp get_attributes(%{"errors" => errors}) do
    hd(errors)
  end

  # HACK
  defp get_attributes(%{"data" => data}) do
    data
    |> Map.to_list()
    |> hd()
    |> Tuple.to_list()
    |> tl()
    |> hd()
  end

  @spec body(binary) :: map()
  defp body(query) do
    %{
      "operationName" => "",
      "query" => query,
      "variables" => ""
    }
  end
end
