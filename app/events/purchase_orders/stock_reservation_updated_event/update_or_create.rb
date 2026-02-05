module PurchaseOrders
  module StockReservationUpdatedEvent
    class UpdateOrCreate < BaseEvent
      subscribe_to :stock_reservation_updated, prio: 10
      attributes :stock_reservation_id

      def call
        PurchaseOrders::CreateOrUpdateTransaction.call(stock_reservation_id:)
      end
    end
  end
end
