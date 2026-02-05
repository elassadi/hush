module Issues
  class CompleteTransaction < BaseTransaction
    attributes :issue_id
    optional_attributes :relase_stock

    def call
      issue = Issue.find(issue_id)
      document = ActiveRecord::Base.transaction do
        yield complete.call(issue:, relase_stock:)
      end
      Success(document)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def complete = Issues::CompleteOperation
  end
end
