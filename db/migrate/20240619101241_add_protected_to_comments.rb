class AddProtectedToComments < ActiveRecord::Migration[7.0]
  def change
    # Add a new column to the comments table
    add_column :comments, :protected, :boolean, default: false
  end
end
