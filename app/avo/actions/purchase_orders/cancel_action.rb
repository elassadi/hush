module PurchaseOrders
  class CancelAction < ::ApplicationBaseAction
    self.no_confirmation = true
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/solid/x-circle"
    self.icon_class = "text-red-500"

    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:cancel, resource.model)
    end

    def handle(**args)
      model = args[:models].first
      authorize_and_run(:cancel, model) do |issue|
        cancel(issue)
      end
    end

    private

    def cancel(_issue)
      PurchaseOrders::TransitionToTransaction.call(
        purchase_order_id: purchase_order.id, event: :cancel, owner: Current.user
      )
    end
  end
end
