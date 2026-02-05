module Devices
  class UpdateTransaction < BaseTransaction
    attributes :device_id, :device_model_id, :device_color_id
    optional_attributes :imei, :serial_number, :unlock_pattern, :unlock_pin

    def call
      device = Device.by_account.find(device_id)
      ActiveRecord::Base.transaction do
        yield update_device.call(
          device:,
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

    def update_device = Devices::UpdateOperation
  end
end
