module Issues
  module WorkflowEvents
    class Cancel < ::RecloudCore::DryBase
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
        Issues::CancelTransaction.call(issue_id: resource.id)
      end
    end
  end
end
