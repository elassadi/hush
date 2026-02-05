class RemoveSkuFromArticles < ActiveRecord::Migration[7.0]
  def change
    #rename_column :articles, :sku, :_sku

    sql_queries=%{
      UPDATE supplier_sources SET ean="G924563-duplicate" WHERE ean="G924563" LIMIT 1;
      UPDATE supplier_sources SET ean="4051805617746-duplicate" WHERE ean="4051805617746" LIMIT 1;
      UPDATE articles AS a SET ean =(select ean from supplier_sources WHERE article_id=a.id and ean is not null LIMIT 1 ) WHERE ean IS NULL;
      UPDATE articles AS a SET ean =(select concat("ean_",uuid) from supplier_sources WHERE article_id=a.id LIMIT 1 ) WHERE ean IS NULL;
      UPDATE articles AS a SET ean = concat("ean_",uuid) WHERE ean IS NULL;

      }
      #ALTER TABLE articles DROP INDEX `index_on_sku` ;
    sql_queries.split("\n").each do |sql|
      execute(sql) if sql.present?
    end

    change_column :articles, :ean, :string, limit: 63, null: true, index: {unique: true}
    #remove_column :articles, :_sku
    #remove_column :supplier_sources, :ean

  end
end
