module Issues
  module WorkflowConditions
    class DeviceIsReceived < ::RecloudCore::DryBase
      attributes :resource

      def call
        process_condition
      end

      def process_condition
        if resource.device_received
          Success(true)
        else
          Failure(" device is not received yet.")
        end
      end
    end
  end
end
