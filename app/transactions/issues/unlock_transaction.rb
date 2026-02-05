module Issues
  class UnlockTransaction < BaseTransaction
    attributes :issue_id
    optional_attributes :expired_unlock

    def call
      issue = Issue.find(issue_id)
      ActiveRecord::Base.transaction do
        yield unlock_issue.call(issue:, expired_unlock:)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def unlock_issue = Issues::UnlockOperation
  end
end
