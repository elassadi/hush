class CreateStockReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_reservations do |t|

      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 36, null: false
      t.string "status", limit: 63, null: false, index: true
      t.integer "article_id", null: false, index: true
      t.integer "prio", default: 0, null: false
      t.integer "originator_id", index: true
      t.string "originator_type", limit: 63, index: true
      t.integer "qty", null: false
      t.datetime "reserved_at", precision: 6
      t.datetime "fulfilled_at", precision: 6
      t.datetime "fulfill_before", precision: 6
      t.timestamps
    end
  end
end


