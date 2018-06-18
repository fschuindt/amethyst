defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string, null: false
      add :api_token, :string

      timestamps()
    end
  end
end
