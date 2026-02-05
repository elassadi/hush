class AddColumnMerchantIdToCalendarEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_entries, :merchant_id, :integer, null: true, index: true
    ActiveRecord::Base.connection.execute("UPDATE calendar_entries SET merchant_id = (SELECT id FROM merchants WHERE merchants.account_id = calendar_entries.account_id AND merchants.master = true)")
    change_column_null :calendar_entries, :merchant_id, false
  end
end
