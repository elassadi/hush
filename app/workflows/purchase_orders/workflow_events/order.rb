module PurchaseOrders
  module WorkflowEvents
    class Order < ::RecloudCore::DryBase
      attributes :resource
      def call
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
    end
  end
end
