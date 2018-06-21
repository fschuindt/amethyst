defmodule DataBase.Schemas.AccountMovementTest do
  alias DataBase.Test.Support.Factories.AccountMovements, as: SubjectFactory
  alias DataBase.Schemas.AccountMovement, as: Subject
  alias DataBase.Schemas.AccountHistory, as: History
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "build/3" do
    test "builds a %Movement{} struct with its precise attributes" do
      build = SubjectFactory.build
      result = Subject.build(
        build.account_id, build.amount, build.direction
      )

      assert build == result
    end
  end

  describe "move/1" do
    test "creates a new movement" do
      assert {:ok, %Subject{}} = Subject.move(SubjectFactory.build)
    end

    test "operates value over the account balance" do
      amount = Faker.amount
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      final_balance = D.sub(balance, amount)

      build = Subject.build(account.id, amount, -1)
      Subject.move(build)

      assert :eq == D.cmp(final_balance, Account.balance(account))
    end

    test "has its operation registered" do
      amount = Faker.amount
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      final_balance = D.sub(balance, amount)

      build = Subject.build(account.id, amount, -1)
      Subject.move(build)

      {:ok, report} = History.report(account, :total)

      assert :eq == D.cmp(final_balance, report.final_balance)
      assert :eq == D.cmp(balance, report.inbounds)
      assert :eq == D.cmp(amount, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end

    test "debug" do
      amount = D.new(100.07)
      account = Factories.Accounts.opened
      balance = Account.balance(account)

      final_balance = D.sub(balance, amount)

      build = Subject.build(account.id, amount, -1)
      Subject.move(build)

      {:ok, report} = History.report(account, :total)

      assert :eq == D.cmp(final_balance, report.final_balance)
      assert :eq == D.cmp(balance, report.inbounds)
      assert :eq == D.cmp(amount, report.outbounds)
      assert :eq == D.cmp(0, report.initial_balance)
    end
  end

  describe "valid_amount?/1" do
    test "it's false for zero decimal" do
      assert false == Subject.valid_amount?(Decimal.new(0))
    end

    test "it's false for negative decimals" do
      assert false == Subject.valid_amount?(Faker.amount(-1))
    end

    test "it's true for positive decimals" do
      assert true == Subject.valid_amount?(Faker.amount)
    end
  end

  describe "inbounds_on/1" do
    test "sum account inbounds with inbound movements" do
      amount = Faker.amount
      account = Factories.Accounts.opened
      build = Subject.build(account.id, amount, 1)
      balance = Account.balance(account)

      move_on = %{move_on: Date.utc_today}
      movement = struct(build, move_on)

      inbounds_on = D.add(balance, amount)
      result = Subject.inbounds_on(movement)

      assert :eq == D.cmp(inbounds_on, result)
    end
  end

  describe "outbounds_on/1" do
    test "sum account outbounds with outbound movements" do
      amount = Faker.amount
      account = Factories.Accounts.opened
      build = Subject.build(account.id, amount, -1)

      move_on = %{move_on: Date.utc_today}
      movement = struct(build, move_on)

      result = Subject.outbounds_on(movement)

      assert :eq == D.cmp(amount, result)
    end
  end

  describe "initial_balance_for/1" do
    test "for the first day movement, it's the movement initial balance" do
      amount = Faker.amount
      account = Factories.Accounts.blank
      build = Subject.build(account.id, amount, 1)
      {:ok, movement} = Subject.move(build)

      result = Subject.initial_balance_for(movement)

      assert :eq == D.cmp(movement.initial_balance, result)
    end

    test "other, it's initial_balance from the last day movement" do
      amount = Faker.amount
      account = Factories.Accounts.opened
      build = Subject.build(account.id, amount, 1)
      {:ok, movement} = Subject.move(build)

      result = Subject.initial_balance_for(movement)

      assert :eq == D.cmp(0, result)
    end
  end
end
