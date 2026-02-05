module Issues
  module WorkflowEvents
    module AttAwaitingDeviceEvent
      class NotifyUserBySms < BaseAttEvent
        subscribe_to :after_transition_to_awaiting_device
        attributes :resource_id, :resource_class, :from, :to, :triggering_event, :event_args
        optional_attributes :current_user_id
        delegate :account, to: :issue

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          if sms_notification_enabled? && from_awaiting_parts && not_temporary_transition?
            yield send_sms
            yield create_activity(activity_name: :sms_sent, triggering_event:)
            return Success("SMS notification sent")
          end

          Success("Skipped sending sms notification: #{sms_notification_enabled?} " \
                  "from_awaiting_parts: #{from_awaiting_parts}")
        end

        private

        def sms_notification_enabled?
          account.application_settings.sms_enabled? &&
            notification_rule(:sms)&.status_active?
        end

        def send_sms
          Sms::IssueSimser.call(
            issue:,
            template: notification_rule(:sms).template
          )
        end
      end
    end
  end
end
