# frozen_string_literal: true

module Sms
  class Gateway < ::RecloudCore::DryBase
    attributes :provider, :text, :to
    optional_attributes :delay

    def call
      return log_sms if Rails.env.development? && provider != "recloud"

      provider_class.call(text:, to:)
    end

    private

    def provider_class
      case provider
      when "sms77"
        Sms::Sms77Provider
      when "recloud"
        Sms::RecloudProvider
      when "nexmo"
        # Sms::NexmoProvider
      end
    end

    def log_sms
      CoreLogger.info("SMS sent to #{to}: #{text}")
      Success(true)
    end
  end
end
