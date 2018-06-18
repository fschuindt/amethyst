defmodule DataBase.Schemas.AccountTransfer do
  @moduledoc """
  The centralized agreement for exchanging assets between two
  distinct accounts.

  A transfer between accounts is performed by creating a outbound
  movement to the *sender* account and a inbound movement to the
  *recipient* account.

  This module provides a function to register those two
  `t:DataBase.Schemas.AccountMovement.t/0` as being part of a formal
  transfer.

  See `register/2`.

  Expresses information over the `account_transfers` database table.
  """

  use Ecto.Schema

  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.Account

  @typedoc """
  A `DataBase.Schemas.AccountTransfer` struct.
  """
  @type t :: %__MODULE__{}

  @typedoc """
  A standard Ecto response to `DataBase.Schemas.AccountTransfer` data
  insertion.
  """
  @type response_t :: {:ok, t()} | {:error, any()}

  schema "account_transfers" do
    field :amount,         :decimal
    field :transfer_at,    :utc_datetime

    belongs_to(:sender_account, Account)
    belongs_to(:recipient_account, Account)
    belongs_to(:sender_movement, Movement)
    belongs_to(:recipient_movement, Movement)

    timestamps()
  end

  @doc """
  Builds and registers a `t:t/0`.

  Given the inbound and outbound
  `t:DataBase.Schemas.AccountMovement.t/0`, for the *sender* and
  *recipient* `t:DataBase.Schemas.Account.t/0`, it builds a
  respective `t:t/0` and saves it.
  """
  @spec register(Movement.t, Movement.t) :: response_t()
  def register(%Movement{} = outgoing, %Movement{} = incoming) do
    Repo.insert(build(outgoing, incoming))
  end

  @spec build(Movement.t, Movement.t) :: t()
  defp build(%Movement{} = outgoing, %Movement{} = incoming) do
    %__MODULE__{
      sender_account_id: outgoing.account_id,
      sender_movement_id: outgoing.id,
      recipient_account_id: incoming.account_id,
      recipient_movement_id: incoming.id,
      transfer_at: outgoing.move_at,
      amount: outgoing.amount
    }
  end
end
