# frozen_string_literal: true

module Sms
  module Events
    class SmsFailed < BaseService
      attributes :request

      def call
        response = process_event
        Success(response)
      end

      private

      def process_event
        sms.update!(status: :failed, failed_at: Time.zone.now)
      end

      def sms
        @sms ||= SmsQueue.find_by!(uuid: request.event_uuid)
      end
    end
  end
end
