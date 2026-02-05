class AddInvoicedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :last_invoiced_at, :datetime
  end
end
