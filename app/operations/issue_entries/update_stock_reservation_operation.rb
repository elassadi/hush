module IssueEntries
  class UpdateStockReservationOperation < BaseOperation
    attributes :issue_entry

    def call
      return Success(true) unless issue_entry.stockable?

      result = update_stock_reservation

      stock_reservation = result.success
      if result.success?
        if stock_reservation.saved_changes?
          Event.broadcast(:stock_reservation_updated, stock_reservation_id: stock_reservation.id)
        end
        return Success(stock_reservation)
      end
      Failure(result.failure)
    end

    private

    def update_stock_reservation
      issue_entry.stock_reservation.update!(
        article: issue_entry.article,
        qty: issue_entry.qty,
        prio: priority
      )
      Success(issue_entry.stock_reservation)
    end

    def priority
      issue_entry.issue.status_category_open? ? StockReservation::PRIO_LOW : StockReservation::PRIO_NORMAL
    end
  end
end
