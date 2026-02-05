module Issues
  module WorkflowEvents
    module AttCompletedEvent
      class NotifyUserByEmail < BaseWorkflowEvent
        subscribe_to :after_transition_to_completed
        attributes :resource_id, :resource_class, :from, :to, :triggering_event, :event_args
        optional_attributes :current_user_id

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          if notification_enabled?
            yield send_email
            yield create_activity(triggering_event:)
          end

          Success(true)
        end

        private

        def send_email
          IssueMailer.call(
            issue:,
            documents: [issue.invoice],
            template: notification_rule.template
          ).deliver_now

          Success(true)
        end

        def notification_rule
          @notification_rule ||= ApplicationSetting.customer_notification_for(
            trigger: :issue_completed,
            channel: :mail
          )
        end
      end
    end
  end
end
