module Issues
  module IssueOrderPrintedEvent
    class NotifyUserByEmail < BaseIssueEvent
      subscribe_to :issue_order_printed
      attributes :document_id
      optional_attributes :notify_customer, :current_user_id

      def call
        if notification_enabled?
          yield document_email
          yield create_activity(triggering_event: :issue_order_printed)
        end

        Success(true)
      end

      private

      def document_email
        IssueMailer.call(
          issue:,
          documents: [document],
          template: notification_rule.template
        ).deliver_now

        Success(true)
      end

      def document
        @document ||= Document.find(document_id)
      end

      def issue
        document.documentable
      end

      def notification_enabled?
        notify_customer &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: :issue_order_printed,
          channel: :mail
        )
      end
    end
  end
end
