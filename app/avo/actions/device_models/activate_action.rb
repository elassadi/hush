module DeviceModels
  class ActivateAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-500"

    # test
    self.visible = lambda do
      return false if view == :show && resource.model.status_active?

      current_user.can?(:create, DeviceModel)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |device_model|
          activate(device_model)
        end
      end
    end

    private

    def activate(device_model)
      DeviceModels::ActivateTransaction.call(device_model_id: device_model.id)
    end
  end
end
