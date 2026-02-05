module CalendarEntries
  class ConfirmAction < ::ApplicationBaseAction
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-500"

    # test
    self.visible = lambda do
      return false unless view == :show || view == :edit

      current_user.may?(:confirm, resource.model)
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: :calendar_entry_confirmed
      )
    }, default: true, help: t(:notify_customer_help)

    def handle(**args)
      fields = args[:fields]
      models = args[:models]
      @notify_customer = fields[:notify_customer]

      models.each do |model|
        authorize_and_run(:confirm, model) do |calendar_entry|
          confirm(calendar_entry)
        end
        close_frame if model.reload.confirmed?
      end
    end

    private

    def confirm(calendar_entry)
      CalendarEntries::ConfirmTransaction.call(calendar_entry_id: calendar_entry.id, notify_customer:)
    end
  end
end
