module IssueEntries
  class AddRabattOperation < BaseOperation
    attributes :issue_id, :price

    def call
      result = create_rabatt_issue_entry
      issue_entry = result.success
      if result.success?
        Event.broadcast(:issue_entry_created, issue_entry_id: issue_entry.id)
        return Success(issue_entry)
      end
      Failure(result.failure)
    end

    private

    def create_rabatt_issue_entry
      yield validate_statuses
      issue_entry = update_existing_entry || create_new_rabatt_entry

      return Failure(issue_entry.errors.full_messages) unless issue_entry.valid? && issue_entry.save

      Success(issue_entry)
    end

    def update_existing_entry
      entry = issue.issue_entries.category_rabatt.first
      return unless entry

      entry.update(price:)
      entry
    end

    def create_new_rabatt_entry
      issue.issue_entries.create(article_name: :rabatt, qty: 1, price:, category: :rabatt)
    end

    def issue
      @issue ||= Issue.find(issue_id)
    end

    def validate_statuses
      Success(true)
    end
  end
end
