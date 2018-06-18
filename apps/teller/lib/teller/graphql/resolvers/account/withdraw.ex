defmodule Teller.GraphQL.Resolvers.Account.Withdraw do
  @moduledoc """
  Absinthe resolver to the `DataBase.Services.Account.Withdraw`.

  GraphQL endpoint to allow authorized users to withdraw assets from
  their accounts.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Services.Account.Withdraw, as: WithdrawService
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Schemas.Account

  @typedoc """
  Tuple representing the respective resolution result.
  """
  @type response_t :: {:error, any()} | {:ok, Movement.t()}

  @doc """
  Act as a Absinthe resolver to withdraw assets from account.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: response_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: response_t()

  defp do_resolve(%Account{} = account, args, _info) do
    withdraw(account, args[:amount])
  end

  defp do_resolve(_account, _args, _info), do: Error.unauthorized

  @spec withdraw(any, any) :: response_t()

  defp withdraw(account, %Decimal{} = amount) do
    WithdrawService.perform(account, amount)
  end

  defp withdraw(_account, _amount), do: Error.invalid_input
end
