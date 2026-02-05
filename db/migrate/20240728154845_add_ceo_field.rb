class AddCeoField < ActiveRecord::Migration[7.0]
  def change
    add_column :merchants, :ceo_name, :string
    add_column :merchants, :court_in_charge, :string
    add_column :merchants, :hrb_number, :string
    add_column :merchants, :web_page, :string
  end
end
