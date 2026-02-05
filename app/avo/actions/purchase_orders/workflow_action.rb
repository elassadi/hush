module PurchaseOrders
  class WorkflowAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false unless view == :show

      # TODO
      # PurchaseOrderWorkflow.human_workflow_event_names(resource.model).any?
      true
    end

    field :event,
          as: :select,
          options: lambda { |model:, resource:, view:, field:| # rubocop:todo Lint/UnusedBlockArgument
                     PurchaseOrderWorkflow.human_workflow_event_names(model)
                   },
          display_with_value: true

    field :comment, always_show: true, as: :textarea, stacked: true, show_on: :all, attachment_key: :trix_attachments

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |purchase_order|
          perform_transition(purchase_order, **args[:fields].symbolize_keys)
        end
      end
    end

    private

    def perform_transition(purchase_order, event:, comment: nil)
      PurchaseOrders::TransitionToTransaction.call(
        purchase_order_id: purchase_order.id, event:, comment:, owner: Current.user
      )
    end
  end
end
