module Issues
  class LockAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message).html_safe
    self.icon = "heroicons/outline/lock-closed"

    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:lock, resource.model)
    end

    def handle(**args)
      models = args[:models]

      if Current.account.feature_not_available?(:issue_locking)
        return warn I18n.t('helpers.account.feature_not_available')
      end

      models.each do |model|
        authorize_and_run(:lock, model) do |issue|
          lock(issue)
        end
      end
    end

    private

    def lock(issue)
      Issues::LockTransaction.call(issue_id: issue.id)
    end
  end
end
