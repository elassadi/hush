module PurchaseOrders
  class PurchaseOrderWorkflow < BaseWorkflow
    class << self
      def create(issue)
        PurchaseOrderWorkflow.new(issue, workflow_name: "purchase_order")
      end

      def human_workflow_statuses
        super(PurchaseOrder.new)
      end
    end
  end
end
