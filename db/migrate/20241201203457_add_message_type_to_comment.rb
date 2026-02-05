class AddMessageTypeToComment < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :message_type, :string, limit: 63
    ActiveRecord::Base.connection.execute("UPDATE comments SET message_type = 'privat' where notify_customer_with ='none' ")
  end
end
