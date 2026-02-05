module IssueEntries
  module AfterDestroyedEvent
    class UpdateWorkflowStatus < BaseEvent
      subscribe_to :after_issue_entry_destroyed
      attributes :issue_id

      def call
        Issues::UpdateWorkflowStatusTransaction.call(issue_id:)
      end
    end
  end
end
