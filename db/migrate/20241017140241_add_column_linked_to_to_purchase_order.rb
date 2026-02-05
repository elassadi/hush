class AddColumnLinkedToToPurchaseOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :purchase_orders, :linked_to_id, :integer, default: nil
  end
end
