module CalendarEntries
  class CancelAction < ::ApplicationBaseAction
    attr_reader :notify_customer

    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/x-circle"
    self.icon_class = "text-red-500"

    # test
    self.visible = lambda do
      return false unless view == :show || view == :edit

      current_user.may?(:cancel, resource.model)
    end

    field :notify_customer, as: :boolean, visible: lambda { |resource:|
      ApplicationSetting.customer_notification_for(
        trigger: :calendar_entry_canceld
      )
    }, default: true, help: t(:notify_customer_help)

    def handle(**args)
      fields = args[:fields]
      models = args[:models]
      @notify_customer = fields[:notify_customer]
      models.each do |model|
        authorize_and_run(:cancel, model) do |calendar_entry|
          cancel(calendar_entry)
        end
        close_frame if model.reload.status_canceld?
      end
    end

    private

    def cancel(calendar_entry)
      CalendarEntries::CancelTransaction.call(calendar_entry_id: calendar_entry.id, notify_customer:)
    end
  end
end
