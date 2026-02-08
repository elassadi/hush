module Issues
  class CompleteAction < ::ApplicationBaseAction
    attr_reader :print_invoice, :notify_customer

    MENU_POSITION = 10

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-800"

    self.may_download_file = true

    self.visible = lambda do
      return false unless view == :show
      return false unless resource.model.can_run_event?(:complete)

      current_user.may?(:complete, resource.model)
    end

    field :target, as: :html do |_resource|
      %{
        <div id="preview_document_target" class="max-h-64 overflow-y-auto">
        </div>
      }
    end

    field :print_invoice, as: :boolean, default: true

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: :issue_completed
      )
    }, default: true, help: t(:notify_customer_help)

    field :preview_button, as: :html do |_resource|
      ApplicationBaseAction.preview_button_html("invoice")
    end

    def handle(**args)
      params = args[:fields]
      @print_invoice = params[:print_invoice]
      @notify_customer = params[:notify_customer]

      model = args[:models].first

      yield complete_issue(model)
      print_invoice_and_reload_page(model) if print_invoice
    end

    private

    def print_invoice_and_reload_page(model)
      result = authorize_and_run(:print_invoice, model) do |issue|
        Issues::PrintInvoiceTransaction.call(issue_id: issue.id)
      end

      return fail "#{t(:print_invoice_failed)} with #{result.failure}" if result.failure?

      invoice = result.success
      download invoice.file.blob.download, "#{invoice.sequence_id}.pdf" unless Rails.env.development?
      broadcast_reload_page(model)
    end

    def complete_issue(model)
      authorize_and_run(:complete, model) do |issue|
        complete(issue)
      end
    end

    def broadcast_reload_page(model)
      model.broadcast_invoke_later_to([model.uuid, "show"].join, "window.location.reload")
    end

    def complete(issue)
      Issues::TransitionToTransaction.call(issue_id: issue.id,
                                           event: :complete, comment: nil, owner: Current.user,
                                           event_args: { notify_customer: print_invoice && notify_customer })
    end
  end
end
