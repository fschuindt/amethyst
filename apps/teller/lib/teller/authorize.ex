defmodule Teller.Authorize do
  @moduledoc """
  Act as a Plug to perform authorization and load the context.

  This should be our first connection layer.
  """

  import Plug.Conn

  alias DataBase.{Schemas.Account, Services}

  @doc """
  Plug initializer callback.
  """
  @spec init(Plug.opts) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  When the connection comes, this Plug shall seek for the
  authorization headers and set the authorized
  `t:DataBase.Schemas.Account.t/0` into our Absinthe context.

  The connection flow isn't affected. It's up to the Absinthe
  resolver to decide what to do next.

  The following headers are inspected:
  - `account-id`
  - `api-token`
  """
  @spec call(Plug.Conn.t, Plug.opts) :: Plug.Conn.t()
  def call(conn, _opts) do
    do_call(conn, account_id(conn), api_token(conn))
  end

  @spec do_call(Plug.Conn.t, list, list) :: Plug.Conn.t()

  defp do_call(conn, [account_id | _], [api_token | _]) do
    account_id
    |> Services.Account.Authorize.perform(api_token)
    |> respond(conn)
  end

  defp do_call(conn, _account_id, _api_token) do
    respond(:no_credentials, conn)
  end

  @spec respond(any, Plug.Conn.t) :: Plug.Conn.t()

  defp respond({:ok, %Account{} = account}, conn) do
    Absinthe.Plug.put_options(conn, context: %{account: account})
  end

  defp respond(_any, conn), do: conn

  @spec account_id(Plug.Conn.t) :: [binary()]
  defp account_id(conn) do
    get_req_header(conn, "account-id")
  end

  @spec api_token(Plug.Conn.t) :: [binary()]
  defp api_token(conn) do
    get_req_header(conn, "api-token")
  end
end
