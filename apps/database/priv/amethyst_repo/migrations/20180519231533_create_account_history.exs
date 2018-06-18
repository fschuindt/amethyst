defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountHistory do
  use Ecto.Migration

  def change do
    create table(:account_history, primary_key: false) do
      add :date, :date, null: false, primary_key: true
      add :initial_balance, :decimal, null: false, precision: 19, scale: 4
      add :final_balance, :decimal, null: false, precision: 19, scale: 4
      add :inbounds, :decimal, null: false, precision: 19, scale: 4
      add :outbounds, :decimal, null: false, precision: 19, scale: 4

      add :account_id, references(:accounts), null: false, primary_key: true
    end
  end
end
