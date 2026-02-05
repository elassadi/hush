module Issues
  module WorkflowEvents
    class Complete < ::RecloudCore::DryBase
      attributes :resource, :event_args
      def call
        # return Failure("Issue is not in the correct status")
        result = process_event
        if result.success?
          # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
          return Success(true)
        end

        Failure(result.failure)
      end

      def process_event
        Success(true)
      end

      def release_stock
        event_args[:release_stock]
      end
    end
  end
end
