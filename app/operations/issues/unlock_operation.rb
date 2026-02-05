module Issues
  class UnlockOperation < BaseOperation
    attributes :issue
    optional_attributes :expired_unlock

    def call
      result = unlock_issue
      issue = result.success
      if result.success?
        Event.broadcast(:issue_unlocked, issue_id: issue.id)
        return Success(issue)
      end

      Failure(result.failure)
    end

    private

    def unlock_issue
      yield validate_statuses
      issue.unlock!
      update_workflow.perform_later(
        issue_id: issue.id,
        current_user_id:
      )
      Success(issue)
    end

    def current_user_id
      return Current.user.id unless expired_unlock

      issue.locked_by_user_id
    end

    def validate_statuses
      return Failure("#{self.class} already_unlocked issue_id: #{issue.id}") unless issue.locked?

      Success(true)
    end

    def update_workflow = Issues::UpdateWorkflowStatusTransaction
  end
end
