module Issues
  module WorkflowEvents
    module AttAwaitingPartsEvent
      class CreateOrUpdatePurchaseOrder < BaseWorkflowEvent
        subscribe_to :after_transition_to_awaiting_parts
        attributes :resource_id, :resource_class, :from, :to

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          issue.issue_entries.stockable.each do |issue_entry|
            yield IssueEntries::UpdateStockReservationTransaction.call(issue_entry_id: issue_entry.id)
          end
          yield Issues::UpdateWorkflowStatusTransaction.call(issue_id: issue.id) if issue.issue_entries.stockable.any?
          Success(true)
        end
      end
    end
  end
end
