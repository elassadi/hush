# frozen_string_literal: true

module Sms
  class RecloudSmsApiClient < BaseApiClient
    API_USERNAME = ENV.fetch('RECLOUD_SMS_API_USERNAME')
    API_PASSWORD = ENV.fetch('RECLOUD_SMS_API_PASSWORD')
    RECLOUD_SMS_TEST_PHONE_NUMBER = "+4917681764859"
    API_URL = ENV.fetch('RECLOUD_SMS_API_URL')

    def send_message(text:, to:, uuid:, debug: false)
      return Failure("Message text cannot be blank") if text.blank?
      return Failure("Phone numbers cannot be blank") if to.blank?

      body_params = {
        id: uuid,
        message: text,
        phoneNumbers: Rails.env.production? ? Array(to) : Array(RECLOUD_SMS_TEST_PHONE_NUMBER)
      }

      begin
        send_request(path: '/message', body: body_params)
      rescue Faraday::ConnectionFailed => e
        ErrorTracking.capture_message("Could not connect to Recloud SMS API with error: #{e.inspect} ")
        Failure("Could not connect to Recloud SMS API with error: #{e.inspect} debug: #{debug}")
      end
    end

    private

    def connection
      @connection ||= Faraday.new do |faraday|
        faraday.url_prefix = API_URL
        faraday.request :url_encoded
        faraday.request :json
        faraday.response :json, content_type: 'application/json'
        faraday.adapter Faraday.default_adapter
        faraday.options.timeout = 20          # Read timeout: 5 seconds
        faraday.options.open_timeout = 20     # Connection timeout: 5 seconds

        # Add Basic Authentication
        faraday.basic_auth(API_USERNAME, API_PASSWORD)
      end
    end

    def headers
      {
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    end

    def parse_response(response)
      case response.status
      when 200..299
        Success(response.body)
      else
        Failure("Error #{response.status}: #{response.body}")
      end
    end

    class << self
      def send_message(text:, to:, uuid:)
        new.send_message(text:, to:, uuid:)
      end
    end
  end
end
