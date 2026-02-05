module PurchaseOrders
  module WorkflowEvents
    class OrderDelivered < ::RecloudCore::DryBase
      attributes :resource
      def call
        result = process_event
        return Success(true) if result.success?

        Failure(result.failure)
      end

      def process_event
        yield PurchaseOrders::StockOrderTransaction.call(purchase_order_id: resource.id)
        Success(true)
      end
    end
  end
end
