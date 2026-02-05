# frozen_string_literal: true

module Sms
  class Sms77Provider < ::RecloudCore::DryBase
    require "ruby_sms"
    attributes :text, :to
    optional_attributes :delay

    def call
      sms = RubySms.new(api_key:, user:)
      response = sms.send(to:, text:, delay:)

      return Success(response) if response.success?

      Failure(response.errors)
    end

    private

    def user
      Current.account.application_settings.sms_username
    end

    def api_key
      Current.account.application_settings.sms_password
    end
  end
end
