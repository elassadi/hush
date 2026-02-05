class AddStatusToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :status, :string, limit: 63
    add_column :customers, :deleted_at, :datetime
    ActiveRecord::Base.connection.execute("UPDATE customers SET status = 'active'")
    change_column_null :customers, :status, false


    remove_index :customers, name: "index_customers_on_email"
    remove_index :customers, name: "index_squence_id_unique"


    execute "ALTER TABLE customers ADD active_record BOOLEAN GENERATED ALWAYS AS "\
    "(IF(status like 'active' , 1, NULL)) VIRTUAL;"

    add_index :customers, [:account_id, :email, :active_record], unique: true, name: "index_customers_on_active_email"
    add_index :customers, [:account_id, :sequence_id, :active_record], unique: true, name: "index_customers_on_active_sequence"


  end
end
