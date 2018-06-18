defmodule Teller.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema

  alias Teller.GraphQL.Resolvers

  import_types Teller.GraphQL.Types

  query do
    @desc "Overall report from account daily logbook"
    field :report, type: :account_history do
      resolve &Resolvers.AccountHistory.Overall.resolve/2
    end

    @desc "Single date based report from account daily logbook"
    field :date_report, type: :account_history do
      arg :date,         :date

      resolve &Resolvers.AccountHistory.Date.resolve/2
    end

    @desc "Date range based report from account daily logbook"
    field :period_report, type: :account_history do
      arg :from,         non_null(:date)
      arg :to,           non_null(:date)

      resolve &Resolvers.AccountHistory.Period.resolve/2
    end

    @desc "Month based report from account daily logbook"
    field :month_report, type: :account_history do
      arg :year,           non_null(:integer)
      arg :month,          non_null(:integer)

      resolve &Resolvers.AccountHistory.Month.resolve/2
    end

    @desc "Year based report from account daily logbook"
    field :year_report, type: :account_history do
      arg :year,            non_null(:integer)

      resolve &Resolvers.AccountHistory.Year.resolve/2
    end
  end

  mutation do
    @desc "Open a new account"
    field :open_account, type: :account do
      arg :name, non_null(:string)

      resolve &Resolvers.Account.Open.resolve/2
    end

    @desc "Transfer assets between accounts"
    field :assets_transfer, type: :account_transfer do
      arg :recipient_account_id,     non_null(:id)
      arg :amount,                   non_null(:decimal)

      resolve &Resolvers.Account.Transfer.resolve/2
    end

    @desc "Withdraw assets from account"
    field :assets_withdraw, type: :account_movement do
      arg :amount,         non_null(:decimal)

      resolve &Resolvers.Account.Withdraw.resolve/2
    end
  end
end
