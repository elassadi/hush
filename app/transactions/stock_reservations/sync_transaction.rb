module StockReservations
  class SyncTransaction < BaseTransaction
    attributes :article_id

    def call
      article = Article.find(article_id)
      article.with_lock do
        ActiveRecord::Base.transaction do
          yield sync_stock_reservation.call(article:)
        end
      end
      Success(article)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for article #{article_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def sync_stock_reservation = StockReservations::SyncOperation
  end
end
