class CreateNotificationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 63, null: false, index: {unique: true}
      t.string "status", limit: 63, null: false
      t.string "resource", limit: 63
      t.bigint "sender_id", null: false
      t.bigint "receiver_id", null: false
      t.string "title", null: false
      t.json "metadata"
      t.datetime "deleted_at"
      t.timestamps
    end
  end
end
