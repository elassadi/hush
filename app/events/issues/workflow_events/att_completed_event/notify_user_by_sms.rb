module Issues
  module WorkflowEvents
    module AttCompletedEvent
      class NotifyUserBySms < BaseWorkflowEvent
        subscribe_to :after_transition_to_completed
        attributes :resource_id, :resource_class, :from, :to, :triggering_event, :event_args
        optional_attributes :current_user_id
        delegate :account, to: :issue

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          if sms_notification_enabled?
            yield send_sms
            yield create_activity(activity_name: :sms_sent, triggering_event:)
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

        def notification_rule
          @notification_rule ||= ApplicationSetting.customer_notification_for(
            trigger: :issue_completed,
            channel: :sms
          )
        end
      end
    end
  end
end
