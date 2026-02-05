module Issues
  module WorkflowEvents
    class RequestApproval < ::RecloudCore::DryBase
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
        resource.request_approval_at = Time.zone.now
        resource.save!

        Success(true)
      end
    end
  end
end
