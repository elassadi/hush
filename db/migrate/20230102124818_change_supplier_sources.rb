class ChangeSupplierSources < ActiveRecord::Migration[7.0]



  def change
    change_column :supplier_sources, :stock_status, :string, limit: 63, null: false, index: true
    unless ActiveRecord::Base.connection.column_exists?(:supplier_articles, :int_stock_status)
      add_column :supplier_articles, :int_stock_status, :integer, default: 0, after: :stock_status
    end
  end
end
