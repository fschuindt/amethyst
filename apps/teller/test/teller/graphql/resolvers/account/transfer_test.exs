defmodule Teller.GraphQL.Resolvers.Account.TransferTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account transfer resolver" do
    test "requires authorization" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened

      query = """
      mutation AssetsTransfer {
        assetsTransfer(
          recipientAccountId: #{recipient.id},
          amount: #{Faker.amount}
        ) {
          id
        }
      }
      """

      assert {:error, _conn, _resp} = connect(
        query,
        sender.id,
        Faker.binary
      )
    end

    test "transfers assets from authorized account" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened

      query = """
      mutation AssetsTransfer {
        assetsTransfer(
          recipientAccountId: #{recipient.id},
          amount: #{Faker.amount}
        ) {
          amount
        }
      }
      """

      assert {:ok, _conn, %{"amount" => _amount}} = connect(
        query,
        sender.id,
        sender.api_token
      )
    end

    test "won't transfer invalid data" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened

      query = """
      mutation AssetsTransfer {
        assetsTransfer(
          recipientAccountId: #{recipient.id},
          amount: #{Faker.binary}
        ) {
          amount
        }
      }
      """

      assert {:error, _conn, _resp} = connect(
        query,
        sender.id,
        sender.api_token
      )
    end
  end
end
