defmodule Teller.GraphQL.Resolvers.Account.WithdrawTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account withdraw resolver" do
    test "requires authorization" do
      account = Factories.Accounts.opened

      query = """
      mutation AssetsWithdraw {
        assetsWithdraw(amount: #{Faker.amount}) {
          id
        }
      }
      """

      assert {:error, _conn, _resp} = connect(
        query,
        account.id,
        Faker.binary
      )
    end

    test "withdraws assets from the authorized account" do
      account = Factories.Accounts.opened

      query = """
      mutation AssetsWithdraw {
        assetsWithdraw(amount: #{Faker.amount}) {
          amount
        }
      }
      """

      assert {:ok, _conn, %{"amount" => _amount}} = connect(
        query,
        account.id,
        account.api_token
      )
    end

    test "won't withdraw invalid data" do
      account = Factories.Accounts.opened

      query = """
      mutation AssetsWithdraw {
        assetsWithdraw(amount: #{Faker.binary}) {
          amount
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
