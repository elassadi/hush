module Issues
  class UpdateWorkflowStatusTransaction < BaseTransaction
    attributes :issue_id
    optional_attributes :current_user_id

    def call
      issue = Issue.find(issue_id)

      issue.with_lock do
        issue = ActiveRecord::Base.transaction do
          yield update_workflow_status.call(issue:)
        end
        Success(issue)
      end

      Success(issue)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue failed with #{e.result.failure}"
      )
      raise
    end

    private

    def update_workflow_status = Issues::UpdateWorkflowStatusOperation
  end
end
