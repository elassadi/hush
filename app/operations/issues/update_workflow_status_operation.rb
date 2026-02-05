module Issues
  class UpdateWorkflowStatusOperation < BaseOperation
    attributes :issue

    def call
      save_workflow_status
      result = update_workflow_status
      if result.success?
        issue.broadcast_invoke_later_to([issue.uuid, "show"].join, "window.location.reload") if workflow_status_changed?

        issue.broadcast_invoke_later_to([issue.uuid, "show"].join, "window.recloudReloadIssueEntriesFrame")
        return Success(issue)
      end

      Failure(result.failure)
    end

    private

    def update_workflow_status
      %I[activate deactivate].each do |event|
        result = run_workflow_event(event)
        break if result.success?
      end

      Success(true)
    end

    def save_workflow_status
      @workflow_status = issue.workflow.state
    end

    def workflow_status_changed?
      @workflow_status != issue.reload.workflow.state
    end

    def run_workflow_event(event)
      yield can_run_event?(event)
      yield issue.workflow.run_event!(event)

      Success(true)
    end

    def can_run_event?(event)
      return Success(true) if issue.workflow.can_run_event?(event)

      Failure("Can't run event #{event} on issue #{issue.id}")
    end
  end
end
