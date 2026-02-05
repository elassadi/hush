module Issues
  module WorkflowEvents
    class DeviceReceived < ::RecloudCore::DryBase
      attributes :resource, :event_args
      def call
        result = process_event
        return Success(true) if result.success?

        Failure(result.failure)
      end

      def process_event
        resource.device_received = true unless resource.device_received
        Success(true)
      end
    end
  end
end
