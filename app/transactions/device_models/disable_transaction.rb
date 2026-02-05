module DeviceModels
  class DisableTransaction < BaseTransaction
    attributes :device_model_id

    def call
      device_model = DeviceModel.find(device_model_id)
      ActiveRecord::Base.transaction do
        yield disable_device_model.call(device_model:)
      end
      Success(device_model)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for device_model #{device_model_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def disable_device_model = DeviceModels::DisableOperation
  end
end
