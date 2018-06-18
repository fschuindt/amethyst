defmodule DataBase.Services.Account.OpenTest do
  alias DataBase.Services.Account.Open, as: Subject
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Schemas.Account
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "perform/1" do
    test "opens a new account" do
      build = Factories.Accounts.build

      assert {:ok, %Account{}} = Subject.perform(build)
    end

    test "set its balance to 1000" do
      build = Factories.Accounts.build
      {:ok, account} = Subject.perform(build)

      balance = Account.balance(account)

      assert :eq == D.cmp(1000, balance)
    end

    test "generate its API token" do
      build = Factories.Accounts.build
      {:ok, account} = Subject.perform(build)

      assert account.api_token != nil
    end
  end
end
