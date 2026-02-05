# frozen_string_literal: true

module Sms
  class RecloudProvider < ::RecloudCore::DryBase
    attributes :text, :to
    attr_reader :sms

    MAX_SMS_LENGTH = 160
    MAX_SMS_COUNT = 3

    def call
      yield sanitize_phone_number
      yield validate_phone_number
      yield validate_message_length
      sms = yield create_sms
      yield send_sms(sms)

      Success(sms)
    end

    private

    def send_sms(sms)
      response = RecloudSmsApiClient.send_message(text:,
                                                  to:,
                                                  uuid: sms.uuid)
      unless response.success?
        sms.update!(status: :failed, error: response.failure)
        raise response.failure
        # return Failure(response)
      end

      Success(response.success.body)
    end

    def create_sms
      # text.scan(/.{1,#{MAX_SMS_LENGTH}}/) do |message|
      sms = SmsQueue.create!(account_id: Current.account.id, to:, message: text, credit:,
                             queued_at: Time.zone.now, status: :queued,
                             provider: :recloud,
                             issue:)
      # end

      Success(sms)
    end

    def issue
      # should be as a parameter
    end

    def credit
      messages_count = text.length.to_f / MAX_SMS_LENGTH
      # account.sms_credit * messages_count.ceil
      0.12 * messages_count.ceil
    end

    def sanitize_phone_number
      return Failure("Invalid phone number") if to.blank?

      @to = @to.gsub(/\s+/, '')
      @to = @to.gsub(/\A0{1,2}/, '')

      Success(true)
    end

    def validate_message_length
      return Failure("Message is empty") if text.blank?
      return Failure("Message is too long") if text.length > MAX_SMS_COUNT * MAX_SMS_LENGTH

      Success(true)
    end

    def validate_phone_number
      return Failure("Invalid phone number") unless valid_phone_number_format?
      return Failure("International code not supported") unless german_number?

      Success(to)
    end

    def valid_phone_number_format?
      to.match?(/\A\+?\d{8,15}\z/)
    end

    def german_number?
      if to.start_with?('+')
        to.start_with?('+49')
      else
        # Prepend "+49" if the number doesn't already have a country code
        @to = "+49#{to}"
        true
      end
    end
  end
end
