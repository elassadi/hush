module Issues
  module WorkflowEvents
    class ResetRepairing < ::RecloudCore::DryBase
      attributes :resource, :event_args
      def call
        result = process_event
        if result.success?
          # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
          return Success(true)
        end

        Failure(result.failure)
      end

      def process_event
        return Failure("Report is missing") if event_args[:comment_id].blank?

        Issues::ResetRepairingOperation.new(issue: resource, comment: Comment.find(event_args[:comment_id])).call
      end
    end
  end
end
