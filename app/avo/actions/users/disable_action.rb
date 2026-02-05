module Users
  class DisableAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/x-circle"
    self.icon_class = "text-red-500"

    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:disable, resource.model)
    end

    def handle(**args)
      args[:models].each do |model|
        authorize_and_run(:activate, model) do |user|
          disable(user)
        end
      end
    end

    private

    def disable(user)
      Users::DisableTransaction.call(user_id: user.id)
    end
  end
end
