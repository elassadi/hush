# frozen_string_literal: true

module Suppliers
  class SupplierStockUpdateJob < ApplicationJob
    attr_reader :supplier_id, :supplier

    def perform(supplier_id:)
      @supplier_id = supplier_id
      @supplier = Supplier.find(supplier_id)
      # 1. Update supplier source stock status
      Rails.logger.debug "Updating supplier source stock status..."
      update_supplier_source_stock_status
      # 2. Update supplier source purchase prices
      Rails.logger.debug "Updating supplier source purchase prices..."
      update_supplier_source_purchase_prices
      # 3. Create supplier stock update temp table
      Rails.logger.debug "Creating supplier stock update temp table..."
      create_supplier_stock_update_temp_table
      # 4. Find best supplier for articles
      Rails.logger.debug "Finding best supplier for articles..."
      update_best_supplier_for_articles
      # 5. Update supplier for articles
      Rails.logger.debug "Updating supplier for articles..."
      update_supplier_for_articles
      Rails.logger.debug "Updating repair set prices..."
      update_repair_set_prices
    end

    private

    def update_supplier_source_stock_status
      SupplierSource
        .joins(<<-SQL.squish)
          INNER JOIN `supplier_articles`
          ON (
            `supplier_articles`.`sku` = `supplier_sources`.`sku` AND
            (
              `supplier_articles`.`stock_status` <> `supplier_sources`.`stock_status`
            )
          )
        SQL
        .where(supplier_articles: { supplier_id: })
        .update_all(
          " supplier_sources.stock_status = supplier_articles.stock_status "
        )
    end

    def update_supplier_source_purchase_prices
      SupplierSource
        .joins(<<-SQL.squish)
          INNER JOIN `supplier_articles`
          ON (
            `supplier_articles`.`sku` = `supplier_sources`.`sku` AND
            `supplier_articles`.`purchase_price` <> `supplier_sources`.`purchase_price`
          )
        SQL
        .where(supplier_articles: { supplier_id: })
        .update_all(
          " supplier_sources.purchase_price = supplier_articles.purchase_price,  " \
          "supplier_sources.updated_at= '#{DateTime.now.utc.to_fs(:db)}' "
        )
    end

    def create_supplier_stock_update_temp_table
      ActiveRecord::Base
        .connection.execute("DROP TEMPORARY TABLE IF EXISTS supplier_stock_update_temp")
      ActiveRecord::Base.connection.execute(
        "CREATE  TEMPORARY TABLE supplier_stock_update_temp (
          `article_id` int(11) NOT NULL,
          `supplier_id` int(11) NOT NULL,
          PRIMARY KEY (`article_id`)
        )"
      )
    end

    def update_best_supplier_for_articles
      ActiveRecord::Base.connection.execute(
        "INSERT INTO supplier_stock_update_temp (article_id, supplier_id) " \
        "VALUES #{unique_supplier_source_articles.join(', ')};"
      )
    end

    def unique_supplier_source_articles
      @article_ids = []
      table_data = []
      SupplierSource.select(:article_id, :supplier_id, :account_id)
                    .where(article_id: SupplierSource.select(:article_id).where(supplier_id:),
                           account_id: supplier.account_id)
                    .order(*SupplierSource.supplier_sorting_criteria).each do |source|
        next if @article_ids.include?(source.article_id)

        @article_ids << source.article_id
        table_data << "('#{[source.article_id, source.supplier_id].join("','")}')"
      end
      table_data
    end

    def update_supplier_for_articles
      ActiveRecord::Base.connection.execute(
        " UPDATE articles JOIN supplier_stock_update_temp AS temp  " \
        "ON temp.article_id = articles.id  " \
        "SET articles.supplier_id = temp.supplier_id  "
      )
    end

    def update_repair_set_prices
      Array(@article_ids).each do |article_id|
        repair_set_entries = RepairSetEntry.includes(:repair_set).where(article_id:)
        repair_sets_to_update = repair_set_entries.map(&:repair_set).uniq
        repair_sets_to_update.each do |repair_set|
          repair_set.skip_broadcasting = true
          repair_set.update_set_price
        end
      end
    end
  end
end
