module Issues
  class StopRepairingAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)

    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:edit_workflow, resource.model) && resource.model.can_run_event?(:stop_repairing)
    end

    field :comment, always_show: true, as: :textarea, stacked: true, show_on: :all, attachment_key: :trix_attachments,
                    required: true

    def handle(**args)
      if args[:fields][:comment].blank?
        error t(:comment_is_required).to_s
        keep_modal_open
        return
      end

      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |issue|
          perform_transition(issue, event: :stop_repairing, comment: args[:fields][:comment])
        end
      end
    end

    private

    def perform_transition(issue, event:, comment:)
      Issues::TransitionToTransaction.call(issue_id: issue.id, event:, comment:, owner: Current.user)
    end
  end
end
