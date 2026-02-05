class RenameOriginator < ActiveRecord::Migration[7.0]
  def change
    if PurchaseOrderEntry.column_names.include?('initiator_id')
      rename_column :purchase_order_entries, :initiator_id, :originator_id
      rename_column :purchase_order_entries, :initiator_type, :originator_type
    end
  end
end
