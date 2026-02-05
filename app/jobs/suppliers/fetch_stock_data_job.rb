# frozen_string_literal: true

module Suppliers
  class FetchStockDataJob < ApplicationJob
    def perform
      suppliers.find_each(batch_size: 10) do |supplier|
        Current.user = supplier.account.user
        Suppliers::FetchStockDataTransaction.call(supplier_id: supplier.id)
      end
    end

    def suppliers
      Supplier.status_active
              .where("JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.daily_sync') = '1'")
              .where("JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.stock_api_url') IS NOT NULL")
              .where("JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.stock_api_url') <> '' ")
    end
  end
end
