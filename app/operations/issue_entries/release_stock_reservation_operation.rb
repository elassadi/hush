module IssueEntries
  class ReleaseStockReservationOperation < BaseOperation
    attributes :issue_entry
    delegate :stock_reservation, to: :issue_entry

    def call
      result = release_stock
      if result.success?
        # Event.broadcast(:stock_reservation_released, stock_reservation_id: stock_reservation.id)
        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def release_stock
      yield validate_reservations
      yield release_stock_reservation
      yield create_stock_movement

      Success(true)
    end

    def release_stock_reservation
      stock_reservation.update!(fulfilled_at: Time.zone.now)
      stock_reservation.status_fulfilled!

      Success(true)
    end

    def validate_reservations
      return Failure("Article is not stockable") unless issue_entry.stockable?
      return Failure("Issue entries stockreservation are not reserved") unless stock_reservation.status_reserved?
      return Failure("Issue entries stockreservation are already fulfilled") if stock_reservation.fulfilled_at

      Success(true)
    end

    def create_stock_movement
      StockMovement.create!(
        action: :stock_out,
        action_type: :stock_with_referenz,
        originator: issue_entry,
        owner: Current.user,
        stock_location: stock_area.stock_location,
        stock_area:,
        article: issue_entry.article,
        qty: issue_entry.qty
      )
      Success(true)
    end

    def stock_area
      @stock_area ||= StockItem.by_account.where(article_id: issue_entry.article.id)
                               .order(in_stock: :desc).first.stock_area
    end
  end
end
