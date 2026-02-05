class AddRepairScheduletAtToIsues < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :scheduled_repair_at, :datetime, index: true
  end
end
