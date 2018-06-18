defmodule DataBase.Test.Support.Factories.Accounts do
  @moduledoc """
  A set of pre-built `t:DataBase.Schemas.Account.t/0` to help along
  testing environments.
  """

  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account
  alias DataBase.Services

  @doc """
  A random `t:DataBase.Schemas.Account.t/0` build.
  """
  @spec build() :: Account.t()
  def build do
    %Account{name: Faker.binary}
  end

  @doc """
  A random opened `t:DataBase.Schemas.Account.t/0` build.
  """
  @spec opened() :: Account.t()
  def opened do
    {:ok, account} = Services.Account.Open.perform(build())

    account
  end

  @doc """
  A random registered `t:DataBase.Schemas.Account.t/0` build.
  """
  @spec blank() :: Account.t()
  def blank do
    {:ok, account} = Repo.insert(build())

    account
  end
end

