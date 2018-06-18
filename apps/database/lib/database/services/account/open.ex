defmodule DataBase.Services.Account.Open do
  @moduledoc """
  Acts as a service to **open** a new bank account.
  """

  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.Account, as: Acc
  alias Decimal, as: D

  @credit 1000

  @doc """
  Given a `t:DataBase.Schemas.Account.t/0`, registers it in the
  database.

  It also set a initial inbound movement of `1000.00` as a opening
  credit and generates its API authentication token.

  It's the standard way to open a new account.
  """
  @spec perform(Acc.t) :: Acc.response_t()
  def perform(%Acc{} = base_build) do
    respond(Repo.transaction(fn ->
      with build               <- Acc.set_token(base_build),
           {:ok, account}      <- Acc.create(build),
           {:ok, _credit}      <- Acc.credit(account, credit()) do
        {:ok, account}
      else
        _e ->
          {:error, :failed_open_performance}
      end
    end))
  end

  @spec respond(any) :: Acc.response_t()
  defp respond({:ok, transaction}), do: transaction
  defp respond(_any), do: {:error, :database_failure}

  @spec credit() :: D.t()
  defp credit, do: D.new(@credit)
end
