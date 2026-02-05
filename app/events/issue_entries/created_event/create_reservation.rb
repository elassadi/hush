module IssueEntries
  module CreatedEvent
    class CreateReservation < BaseEvent
      subscribe_to :issue_entry_created, prio: 10
      attributes :issue_entry_id

      def call
        IssueEntries::CreateStockReservationTransaction.call(issue_entry_id:)
      end
    end
  end
end
