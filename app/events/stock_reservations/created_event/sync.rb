module StockReservations
  module CreatedEvent
    class Sync < BaseEvent
      subscribe_to :stock_reservation_created, prio: 10
      attributes :stock_reservation_id

      def call
        stock_reservation = StockReservation.find(stock_reservation_id)
        StockReservations::SyncTransaction.call(article_id: stock_reservation.article_id)
      end
    end
  end
end
