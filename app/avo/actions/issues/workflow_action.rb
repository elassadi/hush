module Issues
  class WorkflowAction < ::ApplicationBaseAction
    attr_reader :comment, :event

    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false unless view == :show

      true
    end

    REQUIRED_COMMENTS_BY_EVENTS = {
      reset_repairing: true
    }.freeze

    field :event,
          as: :select,
          options: lambda { |model:, resource:, view:, field:| # rubocop:todo Lint/UnusedBlockArgument
                     IssueWorkflow.human_workflow_event_names(model)
                   },
          display_with_value: true

    field :comment, always_show: true, as: :textarea, stacked: true, show_on: :all,
                    attachment_key: :trix_attachments, required: true

    def handle(**args)
      @comment = args[:fields][:comment]
      @event = args[:fields][:event]

      result = validate_comments
      if result.failure?
        error(result.failure)
        keep_modal_open
        return
      end

      models = args[:models]
      models.each do |model|
        # we are authorizing the action here in the context of the model class not the instance
        authorize_by_class_and_run(:create, model) do |issue|
          perform_transition(issue)
        end
      end
    end

    private

    def perform_transition(issue)
      Issues::TransitionToTransaction.call(issue_id: issue.id, event:, comment:, owner: Current.user)
    end

    def validate_comments
      return Failure(t(:comment_is_required)) if REQUIRED_COMMENTS_BY_EVENTS[event.to_sym] && comment.blank?

      Success(true)
    end
  end
end
