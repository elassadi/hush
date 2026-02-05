module Issues
  module WorkflowConditions
    class ReadyToRepair < ::RecloudCore::DryBase
      attributes :resource

      def call
        process_condition
      end

      def process_condition
        resource.ready_to_repair? ? Success(true) : Failure("Device is not ready to repair")
      end
    end
  end
end
