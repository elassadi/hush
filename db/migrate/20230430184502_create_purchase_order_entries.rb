class CreatePurchaseOrderEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :purchase_order_entries do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 63, null: false
      t.integer "article_id", null: false, index: true
      t.integer "purchase_order_id", null: false, index: true
      t.decimal "price", precision: 12, scale: 5, null: false
      t.integer "originator_id", index: true
      t.string "originator_type"
      t.integer "qty"
      t.timestamps
    end
  end
end
