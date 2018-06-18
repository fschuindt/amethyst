defmodule DataBase.Test.Support.Factories.AccountMovements do
  @moduledoc """
  A set of pre-built `t:DataBase.Schemas.AccountMovement.t/0` to help
  along testing environments.
  """

  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  @doc """
  A random `t:DataBase.Schemas.AccountMovement.t/0` build.
  """
  @spec build() :: Movement.t()
  def build do
    %Movement{
      account_id: Factories.Accounts.opened.id,
      amount: Faker.amount,
      direction: 1
    }
  end

  @doc """
  A random `t:DataBase.Schemas.AccountMovement.t/0` build with the
  internal values but no logbook register.
  """
  @spec unregistered(DateTime.t, Decimal.t) :: Movement.t()
  def unregistered(at \\ DateTime.utc_now, amount \\ Faker.amount) do
    account = Factories.Accounts.blank

    %Movement{
      account_id: account.id,
      account: account,
      amount: amount,
      direction: 1,
      previous_movement_id: nil,
      move_on: DateTime.to_date(at),
      move_at: at,
      initial_balance: 0,
      final_balance: amount
    }
  end
end
