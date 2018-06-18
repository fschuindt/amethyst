defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountMovementsIndexes do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    with :ok <- create_previous_movement_support_index(),
         :ok <- create_previous_movement_index(),
         do: :ok
  end

  defp create_previous_movement_support_index do
    execute """
      CREATE UNIQUE INDEX CONCURRENTLY
        index_account_movements_to_support_previous_movement_fk
        ON account_movements(account_id, id, final_balance)
     """
  end

  defp create_previous_movement_index do
    execute """
      CREATE UNIQUE INDEX CONCURRENTLY
        index_account_movements_by_previous_movement
        ON account_movements(previous_movement_id)
    """
  end
end
