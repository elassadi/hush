# frozen_string_literal: true

module Issues
  module WorkflowEvents
    class BaseWorkflowEvent < BaseIssueEvent
      NOTIFICATION_GRACE_PERIOD = 5.minutes
      def issue_ressource?
        resource_class.casecmp('issue').zero?
      end

      def issue
        @issue ||= Issue.find(resource_id)
      end

      def notify_customer
        event_args.with_indifferent_access[:notify_customer]
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

      def reschedule_event
        Event.broadcast(
          :after_transition_to_awaiting_device,
          resource_id:,
          resource_class:,
          from:,
          to:,
          triggering_event:,
          event_args:,
          current_user_id:,
          wait: NOTIFICATION_GRACE_PERIOD + 1.minute,
          target_class: self.class.name
        )
      end

      def within_grace_period?
        return true if issue.updated_at > NOTIFICATION_GRACE_PERIOD.ago

        false
      end
    end
  end
end
