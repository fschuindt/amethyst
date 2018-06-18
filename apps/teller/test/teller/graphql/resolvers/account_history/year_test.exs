defmodule Teller.GraphQL.Resolvers.AccountHistory.YearTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account history year resolver" do
    test "requires authorization" do
      account = Factories.Accounts.opened
      {year, _month, _day} = Date.to_erl(Faker.today)

      query = """
      {
        yearReport(year: #{year}) {
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

    test "reports over a year" do
      account = Factories.Accounts.opened
      {year, _month, _day} = Date.to_erl(Faker.today)

      query = """
      {
        yearReport(year: #{year}) {
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

    test "won't report with invalid data" do
      account = Factories.Accounts.opened

      query = """
      {
        yearReport(year: #{Faker.binary}) {
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
