defmodule DataBase.Services.Account.WithdrawTest do
  alias DataBase.Services.Account.Withdraw, as: Subject
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "perform/2" do
    test "removes money from account" do
      account = Factories.Accounts.opened
      pre_balance = Account.balance(account)
      amount = Faker.amount

      {:ok, %Movement{}} = Subject.perform(account, amount)

      pos_balance = Account.balance(account)
      balance = D.sub(pre_balance, amount)

      assert :eq == D.cmp(balance, pos_balance)
    end

    test "it's able to withdraw account's entire balance" do
      account = Factories.Accounts.opened
      amount = Account.balance(account)

      assert {:ok, %Movement{}} = Subject.perform(account, amount)
    end

    test "won't withdraw a amount bigger than account's balance" do
      account = Factories.Accounts.opened
      amount = D.add(Faker.amount, Account.balance(account))

      assert {:error, _} = Subject.perform(account, amount)
    end

    test "won't withdraw zero or negative amounts" do
      account = Factories.Accounts.opened
      amount = Faker.amount(-1)

      assert {:error, _} = Subject.perform(account, D.new(0))
      assert {:error, _} = Subject.perform(account, amount)
    end
  end
end
