module Issues
  class CancelTransaction < BaseTransaction
    attributes :issue_id

    def call
      issue = Issue.find(issue_id)
      ActiveRecord::Base.transaction do
        yield cancel_issue.call(issue:)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def cancel_issue = Issues::CancelOperation
  end
end
