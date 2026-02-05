class AddIndexesToSupplierSourcesOnSku < ActiveRecord::Migration[7.0]
  def change
    execute "CREATE INDEX index_on_sku_only ON supplier_sources (sku)"
    execute "CREATE INDEX index_on_sku_only ON supplier_articles (sku)"
  end
end
