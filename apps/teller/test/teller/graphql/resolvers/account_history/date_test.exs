defmodule Teller.GraphQL.Resolvers.AccountHistory.DateTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account history date resolver" do
    test "requires authorization" do
      account = Factories.Accounts.opened
      today = Date.utc_today

      query = """
      {
        dateReport(date: "#{today}") {
          finalBalance
        }
      }
      """

      assert {:error, _conn, _resp} = connect(
        query,
        account.id,
        Faker.binary
      )
    end

    test "reports over a single date" do
      account = Factories.Accounts.opened
      today = Date.utc_today

      query = """
      {
        dateReport(date: "#{today}") {
          finalBalance
        }
      }
      """

      assert {:ok, _conn, %{"finalBalance" => _balance}} = connect(
        query,
        account.id,
        account.api_token
      )
    end

    test "won't report invalid data" do
      account = Factories.Accounts.opened

      query = """
      {
        dateReport(date: "#{Faker.binary}") {
          finalBalance
        }
      }
      """

      assert {:error, _conn, _resp} = connect(
        query,
        account.id,
        account.api_token
      )
    end
  end
end
