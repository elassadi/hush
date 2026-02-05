module Issues
  class LockTransaction < BaseTransaction
    attributes :issue_id
    optional_attributes :lock_option

    def call
      issue = Issue.find(issue_id)
      ActiveRecord::Base.transaction do
        yield lock_issue.call(issue:, lock_option:)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def lock_issue = Issues::LockOperation
  end
end
