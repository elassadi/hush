module IssueEntries
  class CreateTransaction < BaseTransaction
    attributes :issue_entry_attributes
    def call
      issue_entry = ActiveRecord::Base.transaction do
        yield create_issue_entry.call(**issue_entry_attributes)
      end
      Success(issue_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue_entry failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_issue_entry = IssueEntries::CreateOperation
  end
end
