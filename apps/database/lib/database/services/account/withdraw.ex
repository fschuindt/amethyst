defmodule DataBase.Services.Account.Withdraw do
  @moduledoc """
  Acts as a service to **withdraw** assets from a account.
  """

  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.Account, as: Acc
  alias Decimal, as: D

  @doc """
  Given a `t:DataBase.Schemas.Account.t/0` and a `t:Decimal.t/0`
  amount, it performs the withdraw.

  ## Steps Performed
  - Checks if the amount is greater than zero.
  - Checks if the account has the required amount to withdraw.
  - Debit the account.

  It's the standard way to withdraw assets from a account.
  """
  @spec perform(Acc.t, D.t) :: Movement.response_t()
  def perform(%Acc{} = account, %D{} = amount) do
    respond(Repo.transaction(fn ->
      with true               <- Movement.valid_amount?(amount),
           true               <- Acc.has_funds?(account, amount),
           {:ok, withdraw}    <- Acc.debit(account, amount) do
        {:ok, withdraw}
      else
        _e ->
          {:error, :failed_withdraw_performance}
      end
    end))
  end

  @spec respond(any) :: Movement.response_t()
  defp respond({:ok, transaction}), do: transaction
  defp respond(_any), do: {:error, :database_failure}
end
