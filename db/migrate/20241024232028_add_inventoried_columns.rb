class AddInventoriedColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :inventoried_at, :datetime, index: true, after: :updated_at
    add_column :articles, :inventoried_by_id, :integer, index: true, after: :inventoried_at
    add_column :articles, :metadata, :json, after: :description
  end
end
