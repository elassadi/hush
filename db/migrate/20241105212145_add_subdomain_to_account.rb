class AddSubdomainToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :subdomain, :string, unique: true
  end
end
