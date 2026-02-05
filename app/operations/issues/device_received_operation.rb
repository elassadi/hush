module Issues
  class DeviceReceivedOperation < BaseOperation
    attributes :issue

    def call
      result = device_received

      if result.success?
        Event.broadcast(:issue_device_received, issue_id: issue.id)

        return Success(issue)
      end
      Failure(result.failure)
    end

    private

    def device_received
      yield apply_workflow_statuses

      Success(true)
    end

    def apply_workflow_statuses
      return Failure("Issue is not in the correct status") unless issue.can_run_event?(:device_received)

      yield issue.run_event!(:device_received)
      Success(true)
    end
  end
end
