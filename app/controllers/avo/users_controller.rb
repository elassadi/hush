# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.
module Avo
  class UsersController < BaseResourceController
    def keep_alive
      render json: { message: "OK" }
    end

    def save_model
      return super unless @view == :create

      result = Users::CreateTransaction.call(user_attributes:)
      if result.success?
        @model = result.success
        return true
      end

      @model = result.failure

      # @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      @errors = Array.wrap([@model.errors.full_messages].flatten).compact
      nil
    end

    private

    def user_attributes
      @model.attributes.slice(*%w[name email account role_name password api_only]).merge(
        account: Current.user.account,
        role_name: @model.role&.name,
        password: SecureRandom.uuid,
        skip_verification: true,
        send_reset_password_instructions: true
      )
    end
  end
end
