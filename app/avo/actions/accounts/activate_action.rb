module Accounts
  class ActivateAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/solid/check-circle"
    self.icon_class = "text-green-500"

    # test
    self.visible = lambda do
      # return unless
      return false if resource.model && !resource.model.can_be_activated?

      current_user.may?(:activate, Account.new)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:activate, model) do |account|
          activate(account)
        end
      end
    end

    private

    def activate(account)
      Accounts::ActivateTransaction.call(account_id: account.id)
    end
  end
end
