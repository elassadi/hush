module Issues
  module IssueOrderPrintedEvent
    class NotifyUserBySms < BaseIssueEvent
      subscribe_to :issue_order_printed
      attributes :document_id
      optional_attributes :notify_customer, :current_user_id
      delegate :account, to: :issue

      def call
        if sms_notification_enabled?
          yield send_sms
          yield create_activity(activity_name: :sms_sent, triggering_event: :issue_order_printed)
        end

        Success(true)
      end

      private

      def send_sms
        Sms::IssueSimser.call(
          issue:,
          template: notification_rule.template
        )
      end

      def document
        @document ||= Document.find(document_id)
      end

      def issue
        document.documentable
      end

      def sms_notification_enabled?
        notify_customer &&
          account.application_settings.sms_enabled? &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: :issue_order_printed,
          channel: :sms
        )
      end
    end
  end
end
