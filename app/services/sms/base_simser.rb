module Sms
  class BaseSimser < ::RecloudCore::DryBase
    delegate :account, to: :record
    delegate :customer, to: :record

    DEV_MOBILE_NUMBER = "+4917681764859".freeze
    MAX_SMS_LENGTH = 153

    def call
      parsed_content = yield parse_template_data
      send_sms(parsed_content)
    end

    private

    def parse_template_data
      data = template.prepare_data(record)

      parsed_content = yield parse_template(template:, data:)
      Success(parsed_content)
    end

    def send_sms(parsed_content)
      yield fail_if_time_restriction

      Sms::Gateway.call(text: strip_content(parsed_content), to:, provider:)
    end

    def fail_if_time_restriction
      return Success(true) if Rails.env.development?

      current_hour = Time.zone.now.hour
      return Failure("SMS cannot be sent between 23:00 and 08:00.") if current_hour >= 23 || current_hour < 8

      Success(true)
    end

    def to
      return DEV_MOBILE_NUMBER if Rails.env.development?

      customer.mobile_number
    end

    def strip_content(parsed_content)
      parsed_content = ActionController::Base.helpers.strip_tags(parsed_content)
      return parsed_content if provider_recloud?

      parsed_content.strip[0..MAX_SMS_LENGTH]
    end

    def parse_template(template:, data:)
      faraday_result = yield ::Templates::ParseOperation.call(template:, data:)
      return Failure("Failed to parse template #{template.name}. check converter") unless faraday_result.success?

      Success(faraday_result.body["body"])
    end

    def provider_recloud?
      provider == "recloud"
    end

    def provider
      return "recloud" if Rails.env.development?

      account.application_settings.sms_provider
    end
  end
end
