module PurchaseOrders
  module StockReservationCreatedEvent
    class UpdateOrCreate < BaseEvent
      subscribe_to :stock_reservation_created, prio: 1
      attributes :stock_reservation_id

      def call
        PurchaseOrders::CreateOrUpdateTransaction.call(stock_reservation_id:)
      end
    end
  end
end
