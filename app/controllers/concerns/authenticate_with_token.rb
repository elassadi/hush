module AuthenticateWithToken
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user

    before_action :authenticate
  end

  private

  def authenticate
    authenticate_user_with_token || render_unauthorized
  end

  def authenticate_user_with_token

    return true if Current.user

    token = authenticate_with_http_token do |token_value, _options|
      ApiToken.status_active.find_by(token: token_value)
    end

    return false unless token

    (@current_user = token.user) && token.user.current_account
  end

  def render_unauthorized
    render json: { message: "Authorization failed" }, status: :unauthorized
  end

  def handle_not_found
    render json: { message: "Record not found" }, status: :not_found
  end
end
