module PurchaseOrderEntries
  class SplitAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message).html_safe
    self.icon = "heroicons/solid/switch-horizontal"

    self.visible = lambda do
      purchase_order = nil

      purchase_order = PurchaseOrder.find params[:id] if view == :index && params[:id].present?

      return false if purchase_order.blank?

      return false unless current_user.can?(:create, purchase_order)
      return false unless purchase_order.status_ordered?
      return false if purchase_order.purchase_order_entries.count == 1

      true
    end

    docs_link(path: '/repair/purchase-order', i18n_key: :help_message)

    field :stock_immediately, as: :boolean, default: false

    def handle(**args)
      entry_quantities = []
      models = args[:models]
      models.each do |model|
        entry_quantities << {
          id: model.id,
          qty: model.qty
        }
      end

      params = args[:fields]
      stock_immediately = params[:stock_immediately].present? ? true : false
      order = models.first.purchase_order

      authorize_and_run(:create, order) do |local_order|
        split_order(local_order, entry_quantities, stock_immediately)
      end
    end

    private

    def split_order(purchase_order, entry_quantities, stock_immediately)
      PurchaseOrders::SplitTransaction.call(
        purchase_order_id: purchase_order.id,
        entry_quantities:,
        stock_immediately:
      )
    end
  end
end
