module Suppliers
  class FetchStockDataTransaction < BaseTransaction
    attributes :supplier_id

    def call
      ActiveRecord::Base.transaction do
        yield fetch_stock_data.call(supplier:)
      end
      Success(true)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for supplier #{supplier.id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def supplier
      @supplier ||= Supplier.by_account.find(supplier_id)
    end

    def fetch_stock_data = Suppliers::FetchStockDataOperation
  end
end
