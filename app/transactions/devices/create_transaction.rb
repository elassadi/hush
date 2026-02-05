module Devices
  class CreateTransaction < BaseTransaction
    attributes :device_model_id, :device_color_id
    optional_attributes :imei, :serial_number, :unlock_pattern, :unlock_pin

    def call
      device = ActiveRecord::Base.transaction do
        yield create_device.call(
          device_model_id:,
          device_color_id:,
          imei:,
          serial_number:,
          unlock_pattern:,
          unlock_pin:
        )
      end
      Success(device)
    rescue Dry::Monads::Do::Halt => e
      capture_transaction_exception(e)
      raise
    end

    private

    def create_device = Devices::CreateOperation
  end
end
