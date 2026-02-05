module Issues
  module WorkflowEvents
    class DoneRepairingSuccessfull < ::RecloudCore::DryBase
      attributes :resource, :event_args
      def call
        result = process_event
        if result.success?
          # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
          return Success(true)
        end

        Failure(result.failure)
      end

      def process_event
        return Failure("Report is missing") if event_args[:comment_id].blank?

        resource.device_repaired = event_args[:repair_result_successfull]
        resource.repair_report_id = event_args[:comment_id]
        resource.save!

        resource.repair_report.update!(protected: true)

        Success(true)
      end
    end
  end
end
