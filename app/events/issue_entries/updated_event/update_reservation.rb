module IssueEntries
  module UpdatedEvent
    class UpdateReservation < BaseEvent
      subscribe_to :issue_entry_updated
      attributes :issue_entry_id

      def call
        IssueEntries::UpdateStockReservationTransaction.call(issue_entry_id:)
      end
    end
  end
end
