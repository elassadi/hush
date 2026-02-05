class CreatePurchaseOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_orders do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 63, null: false
      t.string "status", limit: 63, null: false, index: true
      t.string "status_category", limit: 63, null: false, index: true
      t.json "metadata"
      t.integer "supplier_id", null: false, index: true
      t.integer "tax", default: 19, null: false
      t.decimal "price", precision: 12, scale: 5
      t.timestamps
    end
  end
end
