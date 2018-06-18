defmodule DataBase.Services.Account.Transfer do
  @moduledoc """
  Acts as a service to **transfer** assets between accounts.
  """

  alias DataBase.Schemas.AccountTransfer, as: Transfer
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.Account, as: Acc
  alias Decimal, as: D

  @doc """
  Given two distinct `t:DataBase.Schemas.Account.t/0` and a
  `t:Decimal.t/0` amount, it performs the transfer.

  ## Steps Performed
  - Checks if the amount is greater than zero.
  - Checks if the sender account has the required amount to transfer.
  - Debit the sender account.
  - Credit the recipient account.
  - Registers a new `t:DataBase.Schemas.AccountTransfer.t/0`.

  It's the standard way to transfer assets between accounts.
  """
  @spec perform(Acc.t, Acc.t, D.t) :: Transfer.response_t()
  def perform(%Acc{} = sender, %Acc{} = recipient, %D{} = amount) do
    respond(Repo.transaction(fn ->
      with true               <- Movement.valid_amount?(amount),
           true               <- Acc.has_funds?(sender, amount),
           {:ok, outb}        <- Acc.debit(sender, amount),
           {:ok, inb}         <- Acc.credit(recipient, amount),
           {:ok, transfer}    <- Transfer.register(outb, inb) do
        {:ok, transfer}
      else
        _e ->
          {:error, :failed_transfer_performance}
      end
    end))
  end

  @spec respond(any) :: Transfer.response_t()
  defp respond({:ok, transaction}), do: transaction
  defp respond(_any), do: {:error, :database_failure}
end
