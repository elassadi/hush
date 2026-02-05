module Issues
  class UnlockAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message).html_safe
    self.icon = "heroicons/outline/lock-open"
    self.no_confirmation = true
    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:unlock, resource.model)
    end

    def handle(**args)
      if Current.account.feature_not_available?(:issue_locking)
        return warn I18n.t('helpers.account.feature_not_available')
      end

      models = args[:models]
      models.each do |model|
        authorize_and_run(:lock, model) do |issue|
          unlock(issue)
        end
      end
    end

    private

    def unlock(issue)
      Issues::UnlockTransaction.call(issue_id: issue.id)
    end
  end
end
