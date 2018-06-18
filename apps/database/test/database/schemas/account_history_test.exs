defmodule DataBase.Schemas.AccountHistoryTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Schemas.AccountHistory, as: Subject
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "register/1" do
    test "registers a movement into the history" do
      movement = Factories.AccountMovements.unregistered

      Subject.register(movement)

      {:ok, report} = Subject.report(movement.account, Faker.today)

      assert :eq == D.cmp(movement.amount, report.final_balance)
      assert :eq == D.cmp(movement.amount, report.inbounds)
      assert :eq == D.cmp(0, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end
  end

  describe "report/2" do
    test "reports for a single date" do
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      {:ok, report} = Subject.report(account, Faker.today)

      assert :eq == D.cmp(balance, report.final_balance)
      assert :eq == D.cmp(balance, report.inbounds)
      assert :eq == D.cmp(0, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end

    test "reports for a date range" do
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      {:ok, report} = Subject.report(account, Faker.date_range)

      assert :eq == D.cmp(balance, report.final_balance)
      assert :eq == D.cmp(balance, report.inbounds)
      assert :eq == D.cmp(0, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end

    test "reports total" do
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      {:ok, report} = Subject.report(account, :total)

      assert :eq == D.cmp(balance, report.final_balance)
      assert :eq == D.cmp(balance, report.inbounds)
      assert :eq == D.cmp(0, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end
  end
end
