module Issues
  class UpdateTransaction < BaseTransaction
    attributes :issue_id, :issue_attributes
    def call
      issue = Issue.by_account.find(issue_id)
      ActiveRecord::Base.transaction do
        yield update_issue.call(issue:, **issue_attributes)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue failed with #{e.result.failure}"
      )
      raise
    end

    private

    def update_issue = Issues::UpdateOperation
  end
end
