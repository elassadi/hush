module Users
  class ActivateAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/check-circle"
    self.icon_class = "text-green-500"

    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:activate, resource.model)
    end

    def handle(**args)
      args[:models].each do |model|
        authorize_and_run(:activate, model) do |user|
          activate(user)
        end
      end
    end

    private

    def activate(user)
      Users::ActivateTransaction.call(user_id: user.id)
    end
  end
end
