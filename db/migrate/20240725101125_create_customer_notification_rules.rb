class CreateCustomerNotificationRules < ActiveRecord::Migration[7.0]
  def change
    create_table :customer_notification_rules do |t|
      t.bigint "account_id", null: false, index: true
      t.bigint "setting_id", null: false, index: true
      t.string "uuid", limit: 36, null: false
      t.string "status", limit: 63, null: false, index: true
      t.string "channel", limit: 63, null: false, index: true
      t.integer "template_id", null: false, index: true
      t.json "metadata"

      t.timestamps
    end
  end
end
