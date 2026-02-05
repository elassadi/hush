module Issues
  class TransitionToOperation < BaseOperation
    attributes :issue, :event
    optional_attributes :comment, :owner, :event_args

    def call
      # return Success(issue)
      result = run_event
      return Success(issue) if result.success?

      Failure(result.failure)
    end

    private

    def run_event
      yield can_run_event?
      comment_instance = yield create_comment if comment.present?
      yield run_workflow_event(comment_instance)

      Success(true)
    end

    def create_comment
      return Failure("Can't create comment without owner") if owner.blank?

      comment_instance = issue.comments.create!(
        body: comment,
        owner:
      )
      Success(comment_instance)
    end

    def run_workflow_event(comment_instance)
      args = (event_args || {}).merge(comment_id: comment_instance&.id)
      yield issue.workflow.run_event!(event, event_args: args)

      Success(true)
    end

    def can_run_event?
      return Success(true) if issue.workflow.can_run_event?(event)

      Failure("Can't run event #{event} on issue #{issue.id}")
    end
  end
end
