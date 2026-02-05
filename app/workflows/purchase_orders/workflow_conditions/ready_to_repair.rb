module PurchaseOrders
  module WorkflowConditions
    class ReadyToRepair < ::RecloudCore::DryBase
      attributes :resource

      def call
        result = process_condition
        if result.success?
          # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
          return Success(true)
        end

        Failure(result.failure)
      end

      def process_condition
        Success(true)
      end
    end
  end
end
