module IssueEntries
  class DestroyStockReservationOperation < BaseOperation
    attributes :stock_reservation

    def call
      result = destroy_stock_reservation
      if result.success?
        Event.broadcast(:stock_reservation_destroyed,
                        stock_reservation_id: stock_reservation.id,
                        article_id: stock_reservation.article_id,
                        stock_reservation_hsh: stock_reservation)
        return Success(stock_reservation)
      end
      Failure(result.failure)
    end

    private

    def destroy_stock_reservation
      stock_reservation.destroy!

      Success(stock_reservation)
    end
  end
end
