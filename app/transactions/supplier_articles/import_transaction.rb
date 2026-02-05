module SupplierArticles
  class ImportTransaction < BaseTransaction
    attributes :document_id, :supplier_id

    def call
      ActiveRecord::Base.transaction do
        yield import_supplier_article.call(document:, supplier:)
      end
      Success(document)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for document #{document_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def document
      @document ||= Document.by_account.find(document_id)
    end

    def supplier
      @supplier ||= Supplier.by_account.find(supplier_id)
    end

    def import_supplier_article = SupplierArticles::ImportOperation
  end
end
