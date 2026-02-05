class CreateSmsQueues < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_queues do |t|
      t.bigint :account_id, null: false, index: true
      t.string :uuid, limit: 36, null: false
      t.bigint :issue_id, index: true
      t.string :status, limit: 63, null: false, index: true
      t.integer :credit , null: false, default: 1
      t.string :error, limit: 255
      t.string :provider, limit: 63, default: "recloud"
      t.text :message
      t.string :to, limit: 23
      t.datetime :queued_at
      t.datetime :sent_at
      t.datetime :delivered_at
      t.datetime :received_at
      t.datetime :failed_at
      t.boolean :incoming_sms, default: false

      t.timestamps
    end
  end
end
