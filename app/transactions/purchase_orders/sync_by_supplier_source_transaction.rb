module PurchaseOrders
  class SyncBySupplierSourceTransaction < BaseTransaction
    attributes :supplier_source_id

    def call
      supplier_source = SupplierSource.find(supplier_source_id)
      ActiveRecord::Base.transaction do
        yield sync_by_supplier_source.call(supplier_source:)
      end
      Success(supplier_source)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for source #{supplier_source_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def sync_by_supplier_source = PurchaseOrders::SyncBySupplierSourceOperation
  end
end
