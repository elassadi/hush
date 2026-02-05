module Accounts
  class DisableAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/solid/ban"
    self.icon_class = "text-red-500"

    # test
    self.visible = lambda do
      return unless view == :show

      return unless resource.model.can_be_disabled?

      current_user.may?(:disable, resource.model)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:disable, model) do |account|
          disable(account)
        end
      end
    end

    private

    def disable(account)
      Accounts::DisableTransaction.call(account_id: account.id)
    end
  end
end
