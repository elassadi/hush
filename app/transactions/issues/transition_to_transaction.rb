module Issues
  class TransitionToTransaction < BaseTransaction
    attributes :issue_id, :event
    optional_attributes :comment, :owner, :event_args
    def call
      issue = Issue.find(issue_id)
      issue = ActiveRecord::Base.transaction do
        yield transition_to.call(issue:, event:, comment:, owner:, event_args:)
      end
      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue failed with #{e.result.failure}"
      )
      raise
    end

    private

    def transition_to = Issues::TransitionToOperation
  end
end
