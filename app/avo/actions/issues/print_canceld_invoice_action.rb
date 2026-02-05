module Issues
  class PrintCanceldInvoiceAction < ::ApplicationBaseAction
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/printer"
    self.may_download_file = true

    MENU_POSITION = 10

    self.visible = lambda do
      return false unless view == :show
      return false unless resource.model.can_be_cancel_invoiced?

      current_user.may?(:print_canceld_invoice, resource.model)
    end

    field :target, as: :html do |_resource|
      %{
        <div id="preview_document_target" class="max-h-64 overflow-y-auto">
        </div>
      }
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: :issue_canceld_invoice_printed
      )
    }, default: true

    field :preview_button, as: :html do |_resource|
      ApplicationBaseAction.preview_button_html("canceld_invoice")
    end

    def handle(**args)
      params = args[:fields]
      @notify_customer = params[:notify_customer]

      model = args[:models].first
      result = authorize_and_run(:print_canceld_invoice, model) do |issue|
        print_canceld_invoice(issue)
      end

      return fail t(:print_canceld_invoice_failed) unless result.success?

      invoice = result.success
      download invoice.file.blob.download, "#{invoice.sequence_id}.pdf" unless Rails.env.development?
      broadcast_reload_page(model)
    end

    private

    def broadcast_reload_page(model)
      model.broadcast_invoke_later_to([model.uuid, "show"].join, "window.location.reload")
    end

    def print_canceld_invoice(issue)
      Issues::PrintCanceldInvoiceTransaction.call(issue_id: issue.id, notify_customer:)
    end
  end
end
