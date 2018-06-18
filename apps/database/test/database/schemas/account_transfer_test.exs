defmodule DataBase.Schemas.AccountTransferTest do
  alias DataBase.Schemas.AccountTransfer, as: Subject
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "register/2" do
    test "registers (saves) a account transfer" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened
      amount = Faker.amount

      {:ok, debit} = Account.debit(sender, amount)
      {:ok, credit} = Account.credit(recipient, amount)

      assert {:ok, %Subject{}} = Subject.register(debit, credit)
    end
  end
end
