module StockReservations
  module DestroyedEvent
    class Sync < BaseEvent
      subscribe_to :stock_reservation_destroyed
      attributes :stock_reservation_id, :article_id

      def call
        article = Article.find(article_id)
        StockReservations::SyncTransaction.call(article_id: article.id)
      end
    end
  end
end
