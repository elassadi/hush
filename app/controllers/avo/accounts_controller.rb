# This controller has been generated to enable Rails' resource routes.
# You shouldn't need to modify it in order to use Avo.

module Avo
  class AccountsController < BaseResourceController
    private

    def save_model
      return super unless @view == :create

      result = Accounts::CreateTransaction.call(account_attributes:)

      if result.success?
        @model = result.success
        return true
      end

      @model = result.failure
      @errors = Array.wrap([result.failure, @model.errors.full_messages].flatten).compact
      nil
    end

    def account_attributes
      @model.attributes.slice("name", "email", "account_type", "legal_form", "first_name", "last_name", "plan").merge(
        password: :notset12311
      )
    end
  end
end
