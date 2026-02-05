module Issues
  class StartRepairingAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.no_confirmation = true

    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:edit_workflow, resource.model) && resource.model.can_run_event?(:start_repairing)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create, model) do |issue|
          perform_transition(issue, event: :start_repairing, comment: nil)
        end
      end
    end

    private

    def perform_transition(issue, event:, comment:)
      Issues::TransitionToTransaction.call(issue_id: issue.id, event:, comment:,
                                           owner: Current.user,
                                           event_args: { assignee: Current.user })
    end
  end
end
