defmodule DataBase.Schemas.AccountTest do
  alias DataBase.Test.Support.Factories.Accounts, as: SubjectFactory
  alias DataBase.Schemas.AccountMovement, as: Movement
  alias DataBase.Schemas.Account, as: Subject
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Faker
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "set_token/1" do
    test "sets a API token to Account" do
      build = SubjectFactory.build
      assert build.api_token == nil

      account = Subject.set_token(build)

      assert account.api_token != nil
    end
  end

  describe "create/1" do
    test "creates a Account struct into repo" do
      build = SubjectFactory.build
      assert build.id == nil

      {:ok, account} = Subject.create(build)

      assert account.id != nil
    end
  end

  describe "has_funds/2" do
    test "false when a account has less than the asked amount" do
      account = SubjectFactory.blank
      amount = D.add(Subject.balance(account), Faker.amount)

      assert false == Subject.has_funds?(account, amount)
    end

    test "true when a account has the exact asked amount" do
      account = SubjectFactory.opened
      balance = Subject.balance(account)

      assert true == Subject.has_funds?(account, balance)
    end

    test "true when a account has more than asked amount" do
      account = SubjectFactory.opened
      amount = D.sub(Subject.balance(account), Faker.amount)

      assert true == Subject.has_funds?(account, amount)
    end
  end

  describe "balance/1" do
    test "returns 0 for accounts with no movements" do
      account = SubjectFactory.blank

      assert :eq == D.cmp(0, Subject.balance(account))
    end

    test "returns 1000 for recently opened accounts" do
      account = SubjectFactory.opened

      assert :eq == D.cmp(1000, Subject.balance(account))
    end

    test "reflect results from account operations" do
      amount = Faker.amount
      account = SubjectFactory.blank

      build = Movement.build(account.id, amount, 1)
      Movement.move(build)

      assert :eq == D.cmp(amount, Subject.balance(account))
    end
  end

  describe "debit/2" do
    test "creates a account outbound movement" do
      account = SubjectFactory.opened
      {:ok, debit} = Subject.debit(account, Faker.amount)

      assert account.id == debit.account_id
      assert -1 == debit.direction
    end

    test "reduces the given amount from the account balance" do
      account = SubjectFactory.opened
      balance = Subject.balance(account)
      amount = Faker.amount

      final_balance = D.sub(balance, amount)

      {:ok, _debit} = Subject.debit(account, amount)

      assert :eq == D.cmp(final_balance, Subject.balance(account))
    end
  end

  describe "credit/2" do
    test "increases the given amount to the account balance" do
      account = SubjectFactory.opened
      balance = Subject.balance(account)
      amount = Faker.amount

      final_balance = D.add(balance, amount)

      {:ok, _credit} = Subject.credit(account, amount)

      assert :eq == D.cmp(final_balance, Subject.balance(account))
    end
  end

  describe "inbounds_on/2" do
    test "returns the total inbounds for a given date" do
      account = SubjectFactory.opened
      balance = Subject.balance(account)
      amount = Faker.amount

      inbounds = D.add(balance, amount)
      {:ok, _credit} = Subject.credit(account, amount)

      result = Subject.inbounds_on(account.id, Date.utc_today)

      assert :eq == D.cmp(inbounds, result)
    end
  end

  describe "outbounds_on/2" do
    test "returns the total outbounds for a given date" do
      account = SubjectFactory.opened
      amount = Faker.amount

      outbounds = D.mult(amount, 2)

      {:ok, _debit} = Subject.debit(account, amount)
      {:ok, _debit} = Subject.debit(account, amount)

      result = Subject.outbounds_on(account.id, Date.utc_today)

      assert :eq = D.cmp(outbounds, result)
    end
  end

  describe "early_balance/2" do
    test "returns the initial_balance of a given date" do
      account = SubjectFactory.opened
      result = Subject.early_balance(account.id, Date.utc_today)

      assert :eq == D.cmp(0, result.initial_balance)
    end
  end

  describe "activity_range/1" do
    test "returns the account activity date range" do
      account = SubjectFactory.opened

      range = Faker.date_range(0)
      result = Subject.activity_range(account)

      assert range == result
    end
  end
end
