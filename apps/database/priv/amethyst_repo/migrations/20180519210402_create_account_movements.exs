defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountMovements do
  use Ecto.Migration

  def change do
    create table(:account_movements) do
      add :direction, :integer, null: false
      add :amount, :decimal, null: false, precision: 19, scale: 4
      add :initial_balance, :decimal, null: false, precision: 19, scale: 4
      add :final_balance, :decimal, null: false, precision: 19, scale: 4
      add :move_at, :utc_datetime, null: false
      add :move_on, :date, null: false

      add :account_id, references(:accounts), null: false
      add :previous_movement_id, :integer

      add :outgoing_movement_id, :integer
      add :incoming_movement_id, :integer

      timestamps()
    end

    create index(:account_movements, [:account_id])
    create index(:account_movements, [:direction])
    create index(:account_movements, [:move_on])
  end
end
