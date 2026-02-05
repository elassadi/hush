module PurchaseOrders
  class TransitionToTransaction < BaseTransaction
    attributes :purchase_order_id, :event
    optional_attributes :comment, :owner
    def call
      purchase_order = PurchaseOrder.find(purchase_order_id)
      purchase_order = ActiveRecord::Base.transaction do
        yield transition_to.call(purchase_order:, event:, comment:, owner:)
      end
      Success(purchase_order)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for purchase_order failed with #{e.result.failure}"
      )
      raise
    end

    private

    def transition_to = PurchaseOrders::TransitionToOperation
  end
end
