defmodule Teller.GraphQL.Types do
  @moduledoc false

  use Absinthe.Schema.Notation

  import_types Absinthe.Type.Custom

  @desc "A account"
  object :account do
    field :id,                        :id
    field :name,                      :string
    field :api_token,                 :string
  end

  @desc "A account fund transaction"
  object :account_movement do
    field :id,                        :id
    field :account_id,                :id
    field :amount,                    :decimal
    field :direction,                 :integer
    field :initial_balance,           :decimal
    field :final_balance,             :decimal
    field :move_at,                   :datetime
    field :move_on,                   :date
  end

  @desc "Assets transfers between accounts agreement consolidation"
  object :account_transfer do
    field :id,                        :id
    field :amount,                    :decimal
    field :transfer_at,               :datetime
    field :sender_account_id,         :id
    field :recipient_account_id,      :id
  end

  @desc "Account assets daily logbook"
  object :account_history do
    field :date,                      :date
    field :initial_balance,           :decimal
    field :final_balance,             :decimal
    field :inbounds,                  :decimal
    field :outbounds,                 :decimal
  end
end
