defmodule Teller.GraphQL.Resolvers.AccountHistory.OverallTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account history overall resolver" do
    test "requires authorization" do
      account = Factories.Accounts.opened

      query = """
      {
        report {
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

    test "reports over account activity range" do
      account = Factories.Accounts.opened

      query = """
      {
        report {
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
  end
end
