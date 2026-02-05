module Accounts
  class PurgeAction < ::ApplicationBaseAction
    self.name = "Purge"
    self.icon = "heroicons/solid/trash"
    self.icon_class = "text-red-500"
    self.message = "Are you sure you want to purge the selected accounts? All data will be permanently deleted."

    # test
    self.visible = lambda do
      Current.user.super_admin?
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:purge, model) do |account|
          purge(account)
        end
      end
    end

    private

    def purge(account)
      Accounts::PurgeTransaction.call(account_id: account.id)
    end
  end
end
