defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountTransfers do
  use Ecto.Migration

  def change do
    create table(:account_transfers) do
      add :amount, :decimal, null: false, precision: 19, scale: 4
      add :transfer_at, :utc_datetime, null: false

      add :sender_account_id, references(:accounts), null: false
      add :recipient_account_id, references(:accounts), null: false
      add :sender_movement_id, references(:account_movements), null: false
      add :recipient_movement_id, references(:account_movements), null: false

      timestamps()
    end

    create index(:account_transfers, [:sender_account_id])
    create index(:account_transfers, [:recipient_account_id])
  end
end
