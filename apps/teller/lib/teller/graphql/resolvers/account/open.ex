defmodule Teller.GraphQL.Resolvers.Account.Open do
  @moduledoc """
  Absinthe resolver to the `DataBase.Services.Account.Open`.

  GraphQL endpoint to allow unauthorized users to open new bank
  accounts into Amethyst.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Services.Account.Open, as: OpenService
  alias DataBase.Schemas.Account

  @typedoc """
  Tuple representing the respective resolution result.
  """
  @type response_t :: {:error, any()} | {:ok, Account.t()}

  @doc """
  Act as a Absinthe resolver to open a new account.

  Does not allow creating accounts alongside valid authorization
  headers.
  """
  @spec resolve(Res.arguments, Res.t) :: response_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: response_t()

  defp do_resolve(%Account{} = _account, _args, _info) do
    Error.already_logged
  end

  defp do_resolve(_account, args, _info) do
    OpenService.perform(%Account{name: args[:name]})
  end
end
