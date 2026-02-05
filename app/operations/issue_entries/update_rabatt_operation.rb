module IssueEntries
  class UpdateRabattOperation < BaseOperation
    attributes :issue_entry, :rabatt

    def call
      result = update_rabatt_issue_entry
      issue_entry = result.success
      if result.success?
        Event.broadcast(:issue_entry_updated, issue_entry_id: issue_entry.id)
        return Success(issue_entry)
      end
      Failure(result.failure)
    end

    private

    def update_rabatt_issue_entry
      yield validate_statuses

      yield update_existing_entry

      Success(issue_entry)
    end

    def update_existing_entry
      issue_entry.update(price: rabatt)

      return Failure(issue_entry.errors.full_messages) unless issue_entry.valid?

      Success(issue_entry)
    end

    def validate_statuses
      return Failure("Entry is not in status 'rabatt'") unless issue_entry.category_rabatt?

      Success(true)
    end
  end
end
