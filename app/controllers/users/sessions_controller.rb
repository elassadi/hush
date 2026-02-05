module Users
  class SessionsController < Devise::SessionsController
    include AuthenticateWithOtpTwoFactor

    prepend_before_action :authenticate_with_otp_two_factor,
                          if: -> { action_name == 'create' && otp_two_factor_enabled? }

    protect_from_forgery with: :exception, prepend: true, except: :destroy

    after_action :after_login, only: :create

    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      # respond_with resource, location: after_sign_in_path_for(resource)
      redirect_to after_sign_in_path_for(resource)
    end

    def respond_to_on_destroy
      respond_to do |format|
        format.all { head :no_content }
        format.any(*navigational_formats) do
          redirect_to after_sign_out_path_for(resource_name),
                      status: :see_other, allow_other_host: true
        end
      end
    end

    def login_as
      sign_in(user_from_token)
      redirect_to home_url
    end

    def user_from_token
      token = params[:token]
      User.find(session[token])
    end

    def activation_pending; end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end

    def after_sign_in_path_for(resource_or_scope)
      signed_in_root_path(resource_or_scope)
    end

    def after_sign_out_path_for(resource)
      new_session_path(resource)
      # home_url(subdomain: "app")
    end

    def after_resetting_password_path_for(resource)
      new_session_path(resource)
    end

    def after_login
      Current.user = current_user
      Event.broadcast("user_logged_in", user_id: current_user.id)
    end
  end
end
