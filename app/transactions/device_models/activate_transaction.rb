module DeviceModels
  class ActivateTransaction < BaseTransaction
    attributes :device_model_id

    def call
      device_model = DeviceModel.find(device_model_id)
      ActiveRecord::Base.transaction do
        yield activate_device_model.call(device_model:)
      end
      Success(device_model)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for device_model #{device_model_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def activate_device_model = DeviceModels::ActivateOperation
  end
end
