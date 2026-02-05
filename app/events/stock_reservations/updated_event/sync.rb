module StockReservations
  module UpdatedEvent
    class Sync < BaseEvent
      subscribe_to :stock_reservation_updated, prio: 100
      attributes :stock_reservation_id

      def call
        stock_reservation = StockReservation.find(stock_reservation_id)
        StockReservations::SyncTransaction.call(article_id: stock_reservation.article_id)
        Success(true)
      end
    end
  end
end
