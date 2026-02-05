module IssueEntries
  class UpdateRabattTransaction < BaseTransaction
    attributes :issue_entry_id, :rabatt
    def call
      issue_entry = IssueEntry.find(issue_entry_id)
      result = ActiveRecord::Base.transaction do
        yield update_rabatt.call(issue_entry:, rabatt:)
      end
      Success(result)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed  to update rabatt with #{e.result.failure}"
      )
      raise
    end

    private

    def update_rabatt = IssueEntries::UpdateRabattOperation
  end
end
