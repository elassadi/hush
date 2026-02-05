class AddCanceldInvoicedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :last_invoice_canceld_at, :datetime
  end
end
