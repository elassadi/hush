module StockReservations
  module SyncEvent
    class UpdateIssues < BaseEvent
      subscribe_to :stock_reservation_synced
      attributes :article_id, :issue_ids

      def call
        overall_result = true
        issue_ids.each do |issue_id|
          result = Issues::UpdateWorkflowStatusTransaction.call(issue_id:)
          overall_result = false if result.failure?
        end

        return Success(true) if overall_result

        Failure("Failed to update some issues")
      end
    end
  end
end
