module StockReservations
  class SyncOperation < BaseOperation
    attributes :article
    attr_reader :issue_ids

    def call
      # return unless StockReservation.pending?
      # Todo prevent double sync
      @issue_ids = []
      result = sync_stock_reservation
      article = result.success
      if result.success?
        Event.broadcast(:stock_reservation_synced, article_id: article.id, issue_ids:)
        return Success(article)
      end
      Failure(result.failure)
    end

    private

    def sync_stock_reservation
      yield validate_statuses
      yield reset_reservations
      yield batch_reserve_reservations

      Success(article)
    end

    def reset_reservations
      article.stock.reset_reservations
      @issue_ids = StockReservation.where(article:).where(fulfilled_at: nil).map do |stock_reservation|
        stock_reservation.issue.id
      end
      StockReservation.where(article:).where(fulfilled_at: nil).update(
        reserved_at: nil,
        status: :pending
      )
      reset_reservations_priority
      article.reload

      Success(true)
    end

    def reset_reservations_priority
      StockReservation.where(article:).where(fulfilled_at: nil).each do |stock_reservation|
        prio = stock_reservation.prio
        if stock_reservation.prio <= StockReservation::PRIO_NORMAL
          prio = begin
            if stock_reservation.issue_entry.issue.status_category_open?
              StockReservation::PRIO_LOW
            else
              StockReservation::PRIO_NORMAL
            end
          rescue StandardError
            StockReservation::PRIO_NORMAL
          end
        end
        # in case we want to set a higher prio in the stock ui we should not overwrite it
        stock_reservation.update(prio:)
      end
    end

    def batch_reserve_reservations
      in_stock_available = article.stock.in_stock_available
      stock_reservations = StockReservation.where(fulfilled_at: nil, article:).order(
        [Arel.sql("prio desc"), Arel.sql("fulfill_before IS NULL"), :fulfill_before, :created_at]
      )

      stock_reservations = stock_reservations.sort_by do |reservation|
        if reservation.issue.request_approval_at
          DateTime.parse(reservation.issue.request_approval_at).to_i
        else
          Float::INFINITY
        end
      end

      stock_reservations.each do |stock_reservation|
        in_stock_available = yield reserve_reservation(stock_reservation, in_stock_available)
      end

      Success(true)
    end

    def reserve_reservation(stock_reservation, in_stock_available)
      stock = stock_reservation.stock

      if stock_reservation.qty <= in_stock_available
        stock_reservation.update(reserved_at: Time.zone.now, status: :reserved)
        in_stock_available -= stock_reservation.qty
      end
      stock.update_reservation_quantity_by(stock_reservation.qty)

      Success(in_stock_available)
    end

    def validate_statuses
      # unless stock_reservation.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved stock_reservation_id: #{stock_reservation.id} ")
      # end

      Success(true)
    end
  end
end
