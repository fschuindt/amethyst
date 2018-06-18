defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountMovementsConstraints do
  use Ecto.Migration

  def up do
    with :ok <- add_composite_foreign_key_on_previous_movement(),
         :ok <- add_check_constraints(),
         do: :ok
  end

  def down do
    :ok = drop_foreign_key_constraints()
  end

  defp add_composite_foreign_key_on_previous_movement do
    execute """
      ALTER TABLE account_movements
        ADD CONSTRAINT account_movements_previous_movement_fk
        FOREIGN KEY
          (account_id, previous_movement_id, initial_balance)
        REFERENCES
          account_movements(account_id, id, final_balance)
    """
  end

  defp add_check_constraints do
    execute """
      ALTER TABLE account_movements
        ADD CONSTRAINT positive_amount CHECK (amount > 0),
        ADD CONSTRAINT direction_module_one CHECK (direction IN (1, -1)),
        ADD CONSTRAINT move_on_must_match_move_at
          CHECK (move_at::date BETWEEN move_on - 1 AND move_on + 1),
        ADD CONSTRAINT initial_movement_balance_zero
          CHECK (previous_movement_id IS NOT NULL OR initial_balance = 0),
        ADD CONSTRAINT delta_balance_equals_movement
          CHECK (final_balance - initial_balance = direction * amount)
    """
  end

  defp drop_foreign_key_constraints do
    execute """
      ALTER TABLE account_movements
        DROP CONSTRAINT account_movements_previous_movement_fk
    """
  end
end
