module Issues
  module WorkflowConditions
    class ReadyToRepairAndDeviceIsReceived < ::RecloudCore::DryBase
      attributes :resource

      def call
        process_condition
      end

      def process_condition
        if resource.ready_to_repair? && resource.device_received
          Success(true)
        else
          resource.device_received ? Failure("Device is not ready to repair") : Failure(" device is not received yet.")
        end
      end
    end
  end
end
