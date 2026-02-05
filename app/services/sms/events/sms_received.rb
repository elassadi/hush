# frozen_string_literal: true

module Sms
  module Events
    class SmsReceived < BaseService
      attributes :request

      def call
        response = process_event
        Success(response)
      end

      private

      def process_event
        if incoming_sms?
          create_incoming_sms
        else
          sms.update!(status: :received, received_at: Time.zone.now)
        end
      end

      def sms
        @sms ||= SmsQueue.find_by(uuid: request.event_uuid)
      end

      def incoming_sms?
        sms.blank? && request.event_uuid.blank?
      end

      def create_incoming_sms
        return unless incoming_sms?
        return unless outgoing_sms

        Current.user = outgoing_sms.account.user
        create_sms_queue
        # create_comment
      end

      def create_sms_queue
        SmsQueue.create!(
          account_id: outgoing_sms.account_id,
          uuid: request.incoming_sms_id,
          status: :received,
          received_at: Time.zone.now,
          to: request.incoming_sms_phone_number,
          message: request.incoming_sms_message,
          incoming_sms: true,
          issue: outgoing_sms.issue
        )
      end

      def create_comment
        outgoing_sms.issue.comments.create!(
          account: outgoing_sms.account,
          body: request.incoming_sms_message,
          owner: outgoing_sms.issue.account.user,
          message_type: :incoming,
          notify_customer_with: :none
        )
      end

      def outgoing_sms
        @outgoing_sms ||= SmsQueue.where(to: request.incoming_sms_phone_number, incoming_sms: false)
                                  .order(created_at: :desc).first
      end
    end
  end
end
