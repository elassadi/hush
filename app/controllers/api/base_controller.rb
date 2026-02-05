module Api
  class BaseController < ActionController::API
    include RestApiErrorHandler
    include Response

    include AuthenticateWithToken
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include CurrentUserAndAudit

    rescue_from CanCan::AccessDenied, with: :render_unauthorized
  end
end
