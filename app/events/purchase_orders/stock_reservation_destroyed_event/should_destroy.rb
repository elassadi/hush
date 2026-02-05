module PurchaseOrders
  module StockReservationDestroyedEvent
    class ShouldDestroy < BaseEvent
      subscribe_to :stock_reservation_destroyed
      attributes :stock_reservation_id, :stock_reservation_hsh

      def call
        PurchaseOrders::ShouldDestroyTransaction.call(stock_reservation_hsh:)
      end
    end
  end
end
