defmodule Teller.GraphQL.Resolvers.AccountHistory.PeriodTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account history period resolver" do
    test "requires authorization" do
      account = Factories.Accounts.opened
      from = Date.utc_today
      to = Date.add(from, 10)

      query = """
      {
        periodReport(from: "#{from}", to: "#{to}") {
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

    test "reports over a from/to date pair" do
      account = Factories.Accounts.opened
      from = Date.utc_today
      to = Date.add(from, 10)

      query = """
      {
        periodReport(from: "#{from}", to: "#{to}") {
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
        periodReport(from: #{Faker.binary}, to: #{Faker.binary}) {
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
