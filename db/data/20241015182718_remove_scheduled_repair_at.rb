# frozen_string_literal: true

class RemoveScheduledRepairAt < ActiveRecord::Migration[7.0]
  def up
    return unless column_exists?(:issues, :scheduled_repair_at)
    remove_column :issues, :scheduled_repair_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
