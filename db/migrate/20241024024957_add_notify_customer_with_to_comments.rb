class AddNotifyCustomerWithToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :notify_customer_with, :string, default: "none"
    ActiveRecord::Base.connection.execute("UPDATE comments SET notify_customer_with = 'none'")
    change_column_null :comments, :notify_customer_with, false
  end
end
