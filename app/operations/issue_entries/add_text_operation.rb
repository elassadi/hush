module IssueEntries
  class AddTextOperation < BaseOperation
    attributes :issue_id, :article_name, :qty, :price

    def call
      result = create_text_issue_entry
      issue_entry = result.success
      if result.success?
        Event.broadcast(:issue_entry_created, issue_entry_id: issue_entry.id)
        return Success(issue_entry)
      end
      Failure(result.failure)
    end

    private

    def create_text_issue_entry
      yield validate_statuses

      issue_entry = issue.issue_entries.create(article_name:, qty:, price:, category: :text)

      return Failure(issue_entry.errors.full_messages) unless issue_entry.valid?

      Success(issue_entry)
    end

    def issue
      @issue ||= Issue.find(issue_id)
    end

    def validate_statuses
      Success(true)
    end
  end
end
