module Issues
  module WorkflowEvents
    module AttAwaitingDeviceEvent
      class BaseAttEvent < BaseWorkflowEvent
        DEFAULT_GRACE_PERIOD = 2.minutes

        private

        def not_temporary_transition?
          return true if Rails.env.development?

          issue = Issue.by_account.find(resource_id)
          activity = issue.activities.where(
            "JSON_EXTRACT(JSON_UNQUOTE(metadata), '$.activity_data.to') = 'awaiting_parts'"
          ).last

          activity.nil? || activity.created_at < DEFAULT_GRACE_PERIOD.ago
        end

        def from_awaiting_parts
          from == "awaiting_parts" && to == "awaiting_device"
        end

        def notification_rule(channel)
          @notification_rule ||= ApplicationSetting.customer_notification_for(
            trigger: :issue_awaiting_device,
            channel:
          )
        end
      end
    end
  end
end
