module PurchaseOrders
  class SplitTransaction < BaseTransaction
    attributes :purchase_order_id, :entry_quantities
    optional_attributes :stock_immediately

    def call
      purchase_order = PurchaseOrder.find(purchase_order_id)
      ActiveRecord::Base.transaction do
        yield split_purchase_order.call(purchase_order:, entry_quantities:, stock_immediately:)
      end
      Success(purchase_order)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for purchase_order #{purchase_order_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def split_purchase_order = PurchaseOrders::SplitOperation
  end
end
