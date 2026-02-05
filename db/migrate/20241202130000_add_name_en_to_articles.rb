class AddNameEnToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :name_en, :string, null: true, after: :name
  end
end
