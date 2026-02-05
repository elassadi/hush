module Issues
  class DeviceReceivedAction < ::ApplicationBaseAction
    MENU_POSITION = 10
    self.no_confirmation = true
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-800"

    self.visible = lambda do
      return false unless view == :show

      return false unless resource.model.can_run_event?(:device_received)

      current_user.may?(:device_received, resource.model)
    end

    def handle(**args)
      # params = args[:fields]

      model = args[:models].first
      authorize_and_run(:device_received, model) do |issue|
        device_received(issue)
      end
    end

    private

    def device_received(issue)
      Issues::DeviceReceivedTransaction.call(issue_id: issue.id)
    end
  end
end
