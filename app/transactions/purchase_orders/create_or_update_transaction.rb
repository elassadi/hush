module PurchaseOrders
  class CreateOrUpdateTransaction < BaseTransaction
    attributes :stock_reservation_id

    def call
      stock_reservation = StockReservation.find(stock_reservation_id)
      purchase_order = ActiveRecord::Base.transaction do
        yield create_or_update_purchase_order.call(stock_reservation:)
      end
      Success(purchase_order)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for stock_reservation #{stock_reservation_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_or_update_purchase_order = PurchaseOrders::CreateOrUpdateOperation
  end
end
