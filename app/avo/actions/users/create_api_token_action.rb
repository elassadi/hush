module Users
  class CreateApiTokenAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/plus-circle"

    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:create_api_token, resource.model)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:create_api_token, model) do |user|
          create_api_token(user)
        end
      end
    end

    private

    def create_api_token(user)
      Users::CreateApiTokenTransaction.call(user_id: user.id)
    end
  end
end
