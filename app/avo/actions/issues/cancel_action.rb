module Issues
  class CancelAction < ::ApplicationBaseAction
    self.no_confirmation = false
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/x-circle"
    self.icon_class = "text-red-500"

    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:cancel, resource.model)
    end

    field :comment, always_show: true, as: :textarea, stacked: true, show_on: :all, attachment_key: :trix_attachments,
                    required: true

    def handle(**args)
      if args[:fields][:comment].blank?
        error t(:comment_is_required).to_s
        keep_modal_open
        return
      end

      model = args[:models].first
      authorize_and_run(:cancel, model) do |issue|
        cancel(issue, comment: args[:fields][:comment])
      end
    end

    private

    def cancel(issue, comment:)
      Issues::TransitionToTransaction.call(issue_id: issue.id, event: :cancel, comment:, owner: Current.user)
    end
  end
end
