module Issues
  module WorkflowEvents
    module AttAwaitingDeviceEvent
      class NotifyUserByEmail < BaseAttEvent
        subscribe_to :after_transition_to_awaiting_device
        attributes :resource_id, :resource_class, :from, :to, :triggering_event, :event_args
        optional_attributes :current_user_id

        DEFAULT_GRACE_PERIOD = 2.minutes

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          if email_notification_enabled? && from_awaiting_parts && not_temporary_transition?

            yield send_email
            yield create_activity(triggering_event:)

            return Success("Email notification sent")
          end

          Success("Skipped sending email notification: #{email_notification_enabled?} " \
                  "from_awaiting_parts: #{from_awaiting_parts}")
        end

        private

        def email_notification_enabled?
          notification_rule(:mail)&.status_active?
        end

        def send_email
          IssueMailer.call(
            issue:,
            documents: [],
            template: notification_rule(:mail).template
          ).deliver_now

          Success(true)
        end
      end
    end
  end
end
