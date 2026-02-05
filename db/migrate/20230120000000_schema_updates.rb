class SchemaUpdates < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :merchant_id, :bigint, after: :uuid, null: false, index: true
    rename_column :repair_sets, :target_price_b2b, :retail_price_b2b
    rename_column :repair_sets, :target_price_b2c, :retail_price
    rename_table :repair_order_entries, :issue_entries
    add_column :articles, :pricing_strategie, :string, limit: 63, null: false, after: :article_type
    add_column :articles, :margin, :decimal, precision: 12, scale: 5, default: "0.0", after: :pricing_strategie
    add_column :devices, :metadata, :json, after: :serial_number
    add_column :repair_set_entries, :tax, :bigint, default: 19, null: false
  end
end
