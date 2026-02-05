module Issues
  class CreateTransaction < BaseTransaction
    attributes :issue_attributes
    def call
      issue = ActiveRecord::Base.transaction do
        yield create_issue.call(**issue_attributes)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_issue = Issues::CreateOperation
  end
end
