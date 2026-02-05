module IssueEntries
  module DestroyedEvent
    class DestroyReservation < BaseEvent
      subscribe_to :issue_entry_destroyed, prio: 10
      attributes :stock_reservation_id

      def call
        return Success(true) if stock_reservation_id.blank?

        IssueEntries::DestroyStockReservationTransaction.call(stock_reservation_id:)
      end
    end
  end
end
