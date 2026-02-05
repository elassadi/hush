module Comments
  module CreatedEvent
    class NotifyCustomerBySms < BaseEvent
      subscribe_to :comment_created
      attributes :comment_id
      optional_attributes :current_user_id

      def call
        return Success("Skipped, notifications are disabled ") unless sms_notification_enabled?

        yield send_sms
        yield create_activity(triggering_event:)

        Success("SmS notification sent")
      end

      private

      def create_activity(triggering_event:, activity_name: :sms_sent)
        Activities::CreateTransaction.call(
          activityable: issue,
          activity_name:,
          activity_data: {
            document_id: nil,
            triggering_event:,
            from: issue.status,
            to: issue.status
          },
          owner_id: current_user_id
        )
      end

      def send_sms
        Sms::IssueSimser.call(
          issue:,
          template: notification_rule.template
        )
      end

      def sms_notification_enabled?
        comment.notify_customer_with_sms? &&
          issue.account.application_settings.sms_enabled? &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :sms
        )
      end

      def comment
        @comment ||= Comment.by_account.find(comment_id)
      end

      def issue
        @issue ||= comment.commentable
      end

      def triggering_event
        :comment_created
      end
    end
  end
end
