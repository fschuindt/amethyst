defmodule Teller.GraphQL.Resolvers.Account.OpenTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "account open resolver" do
    test "opens a new bank Account" do
      name = Faker.binary

      query = """
      mutation OpenAccount {
        openAccount(name: "#{name}") {
          name
        }
      }
      """

      assert {:ok, _conn, %{"name" => ^name}} = connect(query)
    end

    test "fails if valid authorization headers passed" do
      account = Factories.Accounts.opened

      query = """
      mutation OpenAccount {
        openAccount(name: "#{Faker.binary}") {
          id
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
