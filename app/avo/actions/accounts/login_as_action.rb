module Accounts
  class LoginAsAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/login"
    self.no_confirmation = true

    self.visible = lambda do
      # return false unless view == :show
      current_user.may?(:login_as, User.new) && current_user.admin?
    end

    def handle(**args)
      account = args[:models].first

      current_user.authorize!(:login_as, user)
      # get master user of this account
      result = Users::LoginAsTransaction.call(user_id: account.user.id)

      if result.success?
        redirect_to("/users/login_as?token=#{login_as_token(account.user)}")
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
