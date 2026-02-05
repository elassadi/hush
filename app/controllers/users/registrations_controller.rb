# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource

    def new
      build_resource
      yield resource if block_given?

      @plan = params[:plan] || :basic
      respond_with resource
    end

    def create
      @plan = params[:user][:plan]
      Current.user = User.system_user
      return unless basic_params_valid?

      result = Accounts::CreateTransaction.call(account_attributes:)
      if result.success?
        resource = result.success.users.last
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          # inactive user or locked
          return redirect_to activation_pending_path if resource.inactive_message.to_s == "inactive"

          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          # respond_with resource, location: after_inactive_sign_up_path_for(resource)
          redirect_to after_inactive_sign_up_path_for(resource), allow_other_host: true
        end
      else
        resource = build_resource(sign_up_params)
        resource.errors.copy!(result.failure.errors) if result.failure.errors.present?
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource, location: registration_path(resource)
      end
    end

    def account_name
      @account_name ||= params[:user][:account_name][0..30].parameterize
    end

    def account_attributes
      {
        email: params[:user][:email],
        name: account_name,
        password: params[:user][:password],
        account_type: :customer,
        legal_form: "Einzelfirma",
        first_name: params[:user][:first_name],
        last_name: params[:user][:last_name],
        plan: @plan
      }
    end

    protected

    def after_sign_in_path_for(resource_or_scope)
      signed_in_root_path(resource_or_scope)
    end

    def basic_params_valid?
      resource = build_resource(sign_up_params)
      resource.role = Role.new

      resource.validate
      return true if resource.valid?

      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource, location: registration_path(resource)
      false
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[agb first_name last_name account_name])
    end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      new_session_path(resource)
      # home_url(subdomain: "www")
      # signed_in_root_path(resource)
    end
  end
end
