module Issues
  module WorkflowEvents
    module AttCompletedEvent
      class ReleaseStock < BaseWorkflowEvent
        subscribe_to :after_transition_to_completed
        attributes :resource_id, :resource_class, :from, :to, :triggering_event, :event_args

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          issue.issue_entries.stockable.each do |issue_entry|
            yield IssueEntries::ReleaseStockReservationTransaction.call(issue_entry_id: issue_entry.id)
          end
          Success(true)
        end

        def release_stock
          event_args[:release_stock]
        end
      end
    end
  end
end
