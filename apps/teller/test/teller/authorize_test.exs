defmodule Teller.AuthorizeTest do
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker

  use ExUnit.Case, async: true

  import Teller.Test.Support.GraphQuery

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "authorize plug" do
    test "loads account context when valid credentials provided" do
      account = Factories.Accounts.opened
      query = "{report {finalBalance}}"

      {:ok, conn, _resp} = connect(
        query,
        account.id,
        account.api_token
      )

      assert account == conn.private.absinthe.context.account
    end

    test "does nothing when invalid credentials provided" do
      account = Factories.Accounts.opened
      query = "{report {finalBalance}}"

      {:error, conn, _resp} = connect(
        query,
        account.id,
        Faker.binary
      )

      assert nil == conn.private[:absinthe]
    end
  end
end
