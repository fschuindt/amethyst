defmodule DataBase.Services.Account.TransferTest do
  alias DataBase.Services.Account.Transfer, as: Subject
  alias DataBase.Schemas.AccountTransfer, as: Transfer
  alias DataBase.Repos.AmethystRepo, as: Repo
  alias DataBase.Test.Support.Factories
  alias DataBase.Test.Support.Faker
  alias DataBase.Schemas.Account
  alias Decimal, as: D

  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "perform/3" do
    test "transfers money between accounts" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened
      amount = Faker.amount

      sender_pre_balance = Account.balance(sender)
      recipient_pre_balance = Account.balance(recipient)

      {:ok, %Transfer{}} = Subject.perform(sender, recipient, amount)

      sender_pos_balance = Account.balance(sender)
      recipient_pos_balance = Account.balance(recipient)

      sender_balance = D.sub(sender_pre_balance, amount)
      recipient_balance = D.add(recipient_pre_balance, amount)

      assert :eq == D.cmp(sender_balance, sender_pos_balance)
      assert :eq == D.cmp(recipient_balance, recipient_pos_balance)
    end

    test "it's able to transfer account's entire balance" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened
      amount = Account.balance(sender)

      {:ok, %Transfer{}} = Subject.perform(sender, recipient, amount)
    end

    test "won't transfer a amount bigger than sender's balance" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened
      amount = D.add(Faker.amount, Account.balance(sender))

      assert {:error, _} = Subject.perform(sender, recipient, amount)
    end

    test "won't transfer zero or negative amounts" do
      sender = Factories.Accounts.opened
      recipient = Factories.Accounts.opened
      amount = Faker.amount(-1)

      assert {:error, _} = Subject.perform(sender, recipient, D.new(0))
      assert {:error, _} = Subject.perform(sender, recipient, amount)
    end
  end
end
