defmodule DataBase.Services.Account.AuthorizeTest do
  alias DataBase.Services.Account.Authorize, as: Subject
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "perform/2" do
    test "authorizes when proper credentials provided" do
      account = Factories.Accounts.opened
      id = account.id
      token = account.api_token

      assert {:ok, %Account{id: ^id}} = Subject.perform(id, token)
    end

    test "denies when wrong credentials are provided" do
      account = Factories.Accounts.opened
      id = account.id
      token = Faker.binary

      assert {:error, :unauthorized} = Subject.perform(id, token)
    end
  end
end
