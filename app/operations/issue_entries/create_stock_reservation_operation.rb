module IssueEntries
  class CreateStockReservationOperation < BaseOperation
    attributes :issue_entry
    attr_reader :new_record

    def call
      result = create_stock_reservation
      stock_reservation = result.success
      if result.success?
        Event.broadcast(:stock_reservation_created, stock_reservation_id: stock_reservation.id) if new_record
        return Success(stock_reservation)
      end
      Failure(result.failure)
    end

    private

    def create_stock_reservation
      return Success(issue_entry.stock_reservation) if issue_entry.stock_reservation.present?
      return Success(issue_entry) unless issue_entry.stockable?

      stock_reservation = StockReservation.create!(
        account_id: issue_entry.issue.account_id,
        status: :pending,
        originator: issue_entry,
        article: issue_entry.article,
        qty: issue_entry.qty,
        prio: priority
      )
      @new_record = true
      Success(stock_reservation)
    end

    def priority
      issue_entry.issue.status_category_open? ? StockReservation::PRIO_LOW : StockReservation::PRIO_NORMAL
    end
  end
end
