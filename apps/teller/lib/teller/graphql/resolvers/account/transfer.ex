defmodule Teller.GraphQL.Resolvers.Account.Transfer do
  @moduledoc """
  Absinthe resolver to the `DataBase.Services.Account.Transfer`.

  GraphQL endpoint to allow authorized users to transfer assets to
  other `t:DataBase.Schemas.Account.t/0`.
  """

  alias Absinthe.Resolution, as: Res
  alias Teller.ErrorMessages, as: Error
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Services.Account.Transfer, as: TransferService
  alias DataBase.Schemas.AccountTransfer, as: Transfer
  alias DataBase.Schemas.Account

  @typedoc """
  Tuple representing the respective resolution result.
  """
  @type response_t :: {:error, any()} | {:ok, Transfer.t()}

  @doc """
  Act as a Absinthe resolver to transfer assets between accounts.

  The client must provide authorization headers.
  """
  @spec resolve(Res.arguments, Res.t) :: response_t()
  def resolve(args, info) do
    do_resolve(info.context[:account], args, info)
  end

  @spec do_resolve(any, Res.arguments, Res.t) :: response_t()

  defp do_resolve(%Account{} = sender, args, _info) do
    with recipient_id       <- args[:recipient_account_id],
         amount             <- args[:amount],
         false              <- is_nil(recipient_id),
         false              <- is_nil(amount),
         recipient          <- Repo.get(Account, recipient_id),
         %Account{}         <- recipient,
         perform            <- &(TransferService.perform/3),
         {:ok, transfer}    <- perform.(sender, recipient, amount) do
      {:ok, transfer}
    else
      false ->
        Error.required_input
      nil ->
        Error.invalid_recipient
      {:error, _} ->
        Error.insufficient_funds
      _ ->
        Error.operation_failed
    end
  end

  defp do_resolve(_sender, _args, _info), do: Error.unauthorized
end
