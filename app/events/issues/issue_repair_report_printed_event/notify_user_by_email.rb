module Issues
  module IssueRepairReportPrintedEvent
    class NotifyUserByEmail < BaseIssueEvent
      # we disable this notification since its already handled by AttRepairingSuccessfullEvent::NotifyUserByEmail event
      subscribe_to :__issue_repair_report_printed__
      attributes :document_id
      optional_attributes :notify_customer, :current_user_id

      def call
        if notification_enabled?
          yield document_email
          yield create_activity(triggering_event:)
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

      def notification_enabled?
        notify_customer &&
          notification_rule&.status_active?
      end

      def triggering_event
        issue.device_repaired ? :issue_repairing_successfull : :issue_repairing_unsuccessfull
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :mail
        )
      end

      def issue
        document.documentable
      end
    end
  end
end
