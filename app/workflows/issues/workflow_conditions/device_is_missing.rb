module Issues
  module WorkflowConditions
    class DeviceIsMissing < ::RecloudCore::DryBase
      attributes :resource

      def call
        process_condition
      end

      def process_condition
        return Success(true) unless resource.device_received?

        Failure("Device is not missing")
      end
    end
  end
end
