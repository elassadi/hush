module Issues
  class PrintKvaAction < ::ApplicationBaseAction
    MENU_POSITION = 30
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/plus-circle"
    self.may_download_file = true

    self.visible = lambda do
      return false unless view == :show

      return false unless resource.model.can_run_event?(:print_kva)

      current_user.may?(:print_kva, resource.model)
    end

    field :target, as: :html do |_resource|
      %{
        <div id="preview_document_target" class="max-h-64 overflow-y-auto">
        </div>
      }
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: :issue_kva_printed
      )
    }, default: true

    # field :turbo_field, as: :html do |_resource|
    #   # resource_model_id will be replaced with the actual model id when the field
    #   # is rendered inside the html field show component
    #   %{
    #     <turbo-frame id="preview_document" src="/resources/issues/{{resource_model_id}}/preview_document?
    # turbo_frame=preview_document&format=turbo_stream" target="_top">
    #     </turbo-frame>
    #   }
    # end

    field :preview_button, as: :html do |_resource|
      ApplicationBaseAction.preview_button_html("kva")
    end

    def handle(**args)
      params = args[:fields]
      @notify_customer = params[:notify_customer]

      model = args[:models].first
      result = authorize_and_run(:print_kva, model) do |issue|
        print_kva(issue)
      end

      return fail result.failure || t(:print_kva_failed) unless result.success?

      kva_offer = result.success
      download kva_offer.file.blob.download, "#{kva_offer.sequence_id}.pdf" # unless Rails.env.development?
      broadcast_reload_page(model)
    end

    private

    def broadcast_reload_page(model)
      model.broadcast_invoke_later_to([model.uuid, "show"].join, "window.location.reload")
    end

    def print_kva(issue)
      Issues::PrintKvaTransaction.call(issue_id: issue.id, notify_customer:)
    end
  end
end
