module Issues
  class DoneRepairingAction < ::ApplicationBaseAction
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/solid/check-circle"
    self.icon_class = "text-green-500"

    self.visible = lambda do
      return false unless view == :show

      # current_user.may?(:edit_workflow, resource.model) && resource.model.can_run_event?(:done_repairing_successfull)
      true
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: %i[issue_repairing_unsuccessfull issue_repairing_successfull]
      )
    }, default: true

    field :template,
          as: :select, display_with_value: true, placeholder: I18n.t("avo.choose_an_option"),
          include_blank: true,
          options: lambda { |model:, resource:, view:, field:|
            Template.by_account.template_type_repair_report.pluck(:name, :id)
          },
          html: {
            edit: { input: { data: { action: "issue-resource#onTemplateSelectChange" } } }
          }
    field :report, always_show: true, as: :trix, stacked: true, show_on: :all, attachment_key: :trix_attachments,
                   required: true

    def handle(**args)
      fields = args[:fields]
      @notify_customer = fields[:notify_customer]
      if fields[:report].blank? || fields[:template].blank?
        error t(:report_is_missing).to_s
        keep_modal_open
        return
      end

      args[:models].each do |model|
        authorize_by_class_and_run(:create, model) do |issue|
          perform_transition(issue, event: repair_result_event(fields[:template]), report: fields[:report])
        end
      end
    end

    private

    def repair_result_event(template_id)
      template = Template.find(template_id)
      return :done_repairing_successfull if template.tags.include?("successfull")

      :done_repairing_unsuccessfull
    end

    def perform_transition(issue, event:, report:)
      Issues::TransitionToTransaction.call(
        issue_id: issue.id, event:,
        comment: report, owner: Current.user,
        event_args: { repair_result_successfull: event == :done_repairing_successfull,
                      notify_customer: }
      )
    end
  end
end
