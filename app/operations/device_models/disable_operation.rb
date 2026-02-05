module DeviceModels
  class DisableOperation < BaseOperation
    attributes :device_model

    def call
      result = disable_device_model
      device_model = result.success
      if result.success?
        # Event.broadcast(:device_model_activated, device_model_id: device_model.id) if device_model.status_active?
        return Success(device_model)
      end

      Failure(result.failure)
    end

    private

    def disable_device_model
      yield validate_statuses

      device_model.status_disabled!
      # device_model.client.status_active!

      # yield some_other_methods

      Success(device_model)
    end

    def validate_statuses
      unless device_model.status_active?
        return Failure("#{self.class} invalid_status Must be active device_model_id: #{device_model.id} ")
      end

      Success(true)
    end
  end
end
