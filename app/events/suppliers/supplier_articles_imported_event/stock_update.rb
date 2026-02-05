module Suppliers
  module SupplierArticlesImportedEvent
    class StockUpdate < BaseEvent
      subscribe_to :supplier_articles_imported
      attributes :supplier_id

      def call
        Suppliers::SupplierStockUpdateJob.perform_now(supplier_id:)
        Success(true)
      end
    end
  end
end
