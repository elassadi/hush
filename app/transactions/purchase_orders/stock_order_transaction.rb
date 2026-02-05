module PurchaseOrders
  class StockOrderTransaction < BaseTransaction
    attributes :purchase_order_id

    def call
      purchase_order = PurchaseOrder.find(purchase_order_id)
      ActiveRecord::Base.transaction do
        yield stock_order.call(purchase_order:)
      end
      Success(true)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for stock_reservation #{purchase_order_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def stock_order = PurchaseOrders::StockOrderOperation
  end
end
