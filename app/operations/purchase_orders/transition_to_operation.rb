module PurchaseOrders
  class TransitionToOperation < BaseOperation
    attributes :purchase_order, :event
    optional_attributes :comment, :owner

    def call
      result = run_event
      return Success(purchase_order) if result.success?

      Failure(result.failure)
    end

    private

    def run_event
      yield can_run_event?
      yield run_workflow_event
      yield create_comment if comment.present?

      Success(true)
    end

    def create_comment
      return Failure("Can't create comment without owner") if owner.blank?

      purchase_order.comments.create!(
        body: comment,
        owner:
      )
      Success(true)
    end

    def run_workflow_event
      yield purchase_order.workflow.run_event!(event)

      Success(true)
    end

    def can_run_event?
      return Success(true) if purchase_order.workflow.can_run_event?(event)

      Failure("Can't run event #{event} on purchase_order #{purchase_order.id}")
    end
  end
end
