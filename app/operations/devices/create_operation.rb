module Devices
  class CreateOperation < BaseOperation
    attributes :device_model_id, :device_color_id
    optional_attributes :imei, :serial_number, :unlock_pattern, :unlock_pin

    def call
      result = create_device
      device = result.success
      if result.success?
        # Event.broadcast(:device_activated, device_id: device.id) if device.status_active?
        return Success(device)
      end

      Failure(result.failure)
    end

    private

    def create_device
      yield validate_statuses

      device = Device.create(
        device_model_id: device_model_id,
        device_color_id: device_color_id,
        imei: imei,
        serial_number: serial_number,
        unlock_pattern: unlock_pattern,
        unlock_pin: unlock_pin
      )

      return Success(device) if device.valid?

      Failure(device)
    end

    def validate_statuses
      # unless device.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved device_id: #{device.id} ")
      # end

      Success(true)
    end
  end
end
