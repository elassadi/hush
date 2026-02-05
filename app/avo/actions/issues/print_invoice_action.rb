module Issues
  class PrintInvoiceAction < ::ApplicationBaseAction
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/printer"
    self.may_download_file = true
    MENU_POSITION = 10

    self.visible = lambda do
      return false unless view == :show
      return false unless resource.model.can_be_invoiced?

      current_user.may?(:print_invoice, resource.model)
    end

    field :target, as: :html do |_resource|
      %{
        <div id="preview_document_target" class="max-h-64 overflow-y-auto">
        </div>
      }
    end
    field :notify_customer, as: :boolean

    field :preview_button, as: :html do |_resource|
      ApplicationBaseAction.preview_button_html("invoice")
    end

    def handle(**args)
      params = args[:fields]
      @notify_customer = params[:notify_customer]

      model = args[:models].first
      result = authorize_and_run(:print_invoice, model) do |issue|
        print_invoice(issue)
      end

      return fail t(:print_invoice_failed) unless result.success?

      invoice = result.success
      download invoice.file.blob.download, "#{invoice.sequence_id}.pdf" unless Rails.env.development?
      broadcast_reload_page(model)
    end

    private

    def broadcast_reload_page(model)
      model.broadcast_invoke_later_to([model.uuid, "show"].join, "window.location.reload")
    end

    def print_invoice(issue)
      Issues::PrintInvoiceTransaction.call(issue_id: issue.id, notify_customer:)
    end
  end
end
