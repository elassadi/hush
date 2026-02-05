module Issues
  class PrintOrderAction < ::ApplicationBaseAction
    MENU_POSITION = 20
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/printer"
    self.may_download_file = true

    self.visible = lambda do
      return false unless view == :show

      return false unless resource.model.can_run_event?(:print_order)

      current_user.may?(:print_order, resource.model)
    end

    field :target, as: :html do |_resource|
      %{
        <div id="preview_document_target" class="max-h-64 overflow-y-auto">
        </div>
      }
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(trigger: :issue_order_printed)
    }, default: true

    field :preview_button, as: :html do |_resource|
      ApplicationBaseAction.preview_button_html("order")
    end

    def handle(**args)
      params = args[:fields]
      @notify_customer = params[:notify_customer]

      model = args[:models].first
      result = authorize_and_run(:print_order, model) do |issue|
        print_order(issue)
      end

      return fail t(:print_order_failed) unless result.success?

      order_offer = result.success
      download order_offer.file.blob.download, "#{order_offer.sequence_id}.pdf" unless Rails.env.development?
      broadcast_reload_page(model)
    end

    private

    def broadcast_reload_page(model)
      model.broadcast_invoke_later_to([model.uuid, "show"].join, "window.location.reload")
    end

    def print_order(issue)
      Issues::PrintOrderTransaction.call(issue_id: issue.id, notify_customer:)
    end
  end
end
