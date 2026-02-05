# frozen_string_literal: true

module Issues
  module WorkflowEvents
    class BaseWorkflowEvent < BaseIssueEvent
      def issue_ressource?
        resource_class.casecmp('issue').zero?
      end

      def issue
        @issue ||= Issue.find(resource_id)
      end

      def notify_customer
        event_args[:notify_customer]
      end

      def notification_enabled?
        notify_customer &&
          notification_rule&.status_active?
      end

      def sms_notification_enabled?
        notify_customer &&
          account.application_settings.sms_enabled? &&
          notification_rule&.status_active?
      end
    end
  end
end
