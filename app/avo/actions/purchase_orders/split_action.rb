module PurchaseOrders
  class SplitAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message).html_safe
    self.icon = "heroicons/solid/switch-horizontal"

    self.visible = lambda do
      return false unless view == :show

      purchase_order = resource.model

      return false unless current_user.can?(:create, purchase_order)
      return false unless purchase_order.status_ordered?
      return false if purchase_order.purchase_order_entries.count == 1 &&
                      purchase_order.purchase_order_entries.first.qty == 1

      true
    end

    docs_link(path: '/repair/purchase-order', i18n_key: :help_message)

    field :stock_immediately, as: :boolean, default: false

    field :target, as: :html do |_resource|
      %{
        <div id="split_helper_target" class="max-h-64 overflow-y-auto" style="max-height: 280px;overflow-y: auto;">
          <div class="flex justify-center items-center">
            <div class="spinner">
              <div class="double-bounce1 bg-gray-600"></div>
              <div class="double-bounce2 bg-gray-800"></div>
            </div>
          </div>
        </div>
      }
    end

    field :turbo_field, as: :html do |_resource|
      # resource_model_id will be replaced with the actual model id when the field
      # is rendered inside the html field show component
      %{
        <turbo-frame id="split_helper" src="/resources/purchase_orders/
        {{resource_model_id}}
        /split_helper?turbo_frame=split_helper&format=turbo_stream" target="_top">
        </turbo-frame>
      }
    end

    def handle(**args)
      model = args[:models].first
      entry_quantities = []
      params[:fields][:qty].each do |entry_id, qty|
        entry_quantities << {
          id: entry_id,
          qty: qty.to_i
        }
      end

      params = args[:fields]
      stock_immediately = params[:stock_immediately].present? ? true : false
      authorize_and_run(:create, model) do |order|
        split_order(order, entry_quantities, stock_immediately)
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
