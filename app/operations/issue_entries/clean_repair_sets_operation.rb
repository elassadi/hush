module IssueEntries
  class CleanRepairSetsOperation < BaseOperation
    attributes :issue

    def call
      result = remove_repair_set_issue_entries

      return Success(result.success) if result.success?

      Failure(result.failure)
    end

    private

    def remove_repair_set_issue_entries
      yield validate_statuses
      issue_entries = issue.issue_entries.category_repair_set.where.not(repair_set_entry_id: nil)

      issue_entries.destroy_all
      Success(true)
    end

    def issue
      @issue ||= Issue.by_account.find(issue_id)
    end

    def validate_statuses
      if issue.status == 'repairing' || issue.status_category_done?
        return Failure("#{self.class} invalid_status for issue_id: #{issue.id}")
      end

      Success(true)
    end
  end
end
