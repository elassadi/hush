module SupplierArticles
  module ImportRequestedEvent
    class Import < BaseEvent
      subscribe_to :supplier_article_import_requested
      attributes :document_id, :supplier_id

      def call
        yield SupplierArticles::ImportTransaction.call(document_id:, supplier_id:)
        Success(true)
      end
    end
  end
end
