class AddLocaleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :locale, :string, limit:3 ,default: :de, null: false
  end
end
