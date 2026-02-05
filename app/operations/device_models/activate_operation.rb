module DeviceModels
  class ActivateOperation < BaseOperation
    attributes :device_model

    def call
      result = activate_device_model
      device_model = result.success
      if result.success?
        # Event.broadcast(:device_model_activated, device_model_id: device_model.id) if device_model.status_active?
        return Success(device_model)
      end

      Failure(result.failure)
    end

    private

    def activate_device_model
      yield validate_statuses

      device_model.status_active!

      Success(device_model)
    end

    def validate_statuses
      unless device_model.status_disabled?
        return Failure("#{self.class} invalid_status Must be disabled device_model_id: #{device_model.id} ")
      end

      Success(true)
    end
  end
end
