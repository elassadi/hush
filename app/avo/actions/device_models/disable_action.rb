module DeviceModels
  class DisableAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/x-circle"
    self.icon_class = "text-red-500"

    # test
    self.visible = lambda do
      return false if view == :show && resource.model.status_disabled?

      current_user.can?(:create, DeviceModel)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |device_model|
          disable(device_model)
        end
      end
    end

    private

    def disable(device_model)
      DeviceModels::DisableTransaction.call(device_model_id: device_model.id)
    end
  end
end
