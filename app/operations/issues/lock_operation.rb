module Issues
  class LockOperation < BaseOperation
    attributes :issue
    optional_attributes :lock_option

    def call
      result = lock_issue
      issue = result.success
      if result.success?
        Event.broadcast(:issue_locked, issue_id: issue.id)
        return Success(issue)
      end

      Failure(result.failure)
    end

    private

    def lock_issue
      yield validate_statuses
      issue.apply_lock!(lock_option:)
      Success(issue)
    end

    def validate_statuses
      return Failure("#{self.class} already_locked issue_id: #{issue.id}") if issue.locked?

      Success(true)
    end
  end
end
