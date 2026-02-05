module Users
  class LoginAsAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/login"
    self.no_confirmation = true

    # test
    self.visible = lambda do
      # return false unless view == :show
      current_user.may?(:login_as, User.new)
    end

    def handle(**args)
      user = args[:models].first

      return warn t(:user_already_logged_in) if user == Current.user

      current_user.authorize!(:login_as, user)
      result = Users::LoginAsTransaction.call(user_id: user.id)

      if result.success?
        redirect_to("/users/login_as?token=#{login_as_token(user)}")
      else
        error t(:login_as_failed)
      end
    end

    private

    def login_as_token(user)
      token = SecureRandom.uuid
      Current.session[token] = user.id
      token
    end
  end
end
