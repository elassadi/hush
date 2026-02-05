# frozen_string_literal: true

module Sms
  module Webhooks
    class RequestService < BaseService
      attributes :request

      def call
        response = yield process_request
        Success(response)
      end

      private

      def process_request
        unless request.event_type_registered?
          request.status_skipped!
          return Success(request)
        end
        response = yield request.event_type_class.call(request:)
        request.status_success!
        Success(response)
      end
    end
  end
end
