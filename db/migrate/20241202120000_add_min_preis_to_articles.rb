class AddMinPreisToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :min_preis, :decimal, precision: 12, scale: 5, null: true, after: :default_retail_price

    # Update existing records to set min_preis = default_retail_price where min_preis is NULL
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE articles
          SET min_preis = default_retail_price
          WHERE min_preis IS NULL
        SQL
      end
    end
  end
end
