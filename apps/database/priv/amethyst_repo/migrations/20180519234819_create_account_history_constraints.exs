defmodule DataBase.Repos.AmethystRepo.Migrations.CreateAccountHistoryConstraints do
  use Ecto.Migration

  def up do
    with :ok <- add_composite_fk_on_account_movements(),
         :ok <- add_check_constraints(),
         do: :ok
  end

  def down do
    :ok = drop_composite_fk_on_account_movements()
  end

  defp add_composite_fk_on_account_movements do
    execute """
      ALTER TABLE account_movements
        ADD CONSTRAINT account_movements_account_history_fk
          FOREIGN KEY (account_id, move_on)
          REFERENCES account_history(account_id, date)
    """
  end

  defp add_check_constraints do
    execute """
      ALTER TABLE account_history
        ADD CONSTRAINT inbounds_not_negative CHECK (inbounds >= 0),
        ADD CONSTRAINT outbounds_not_negative CHECK (outbounds >= 0),
        ADD CONSTRAINT must_have_changes CHECK (inbounds > 0 OR outbounds > 0),
        ADD CONSTRAINT delta_balance_equals_movement
          CHECK (final_balance - initial_balance = inbounds - outbounds)
    """
  end

  defp drop_composite_fk_on_account_movements do
    execute """
      ALTER TABLE account_movements
        DROP CONSTRAINT account_movements_account_history_fk
    """
  end
end
