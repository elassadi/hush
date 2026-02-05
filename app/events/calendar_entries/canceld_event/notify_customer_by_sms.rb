module CalendarEntries
  module CanceldEvent
    class NotifyCustomerBySms < BaseEvent
      subscribe_to :calendar_entry_canceld
      attributes :calendar_entry_id
      optional_attributes :notify_customer, :current_user_id

      def call
        unless calendar_entry.entry_type.in?(%w[repair regular])
          return Failure("Calendar entry type is not repair or regular")
        end

        if notification_enabled?
          yield send_sms
          yield create_activity(triggering_event:)
          return Success(true)
        end

        Success("Notification not enabled")
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

      def notification_enabled?
        notify_customer &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :sms
        )
      end

      def triggering_event
        :calendar_entry_canceld
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end

      def issue
        @issue ||= calendar_entry.calendarable
      end

      def send_sms
        Sms::CalendarEntrySimser.call(
          calendar_entry:,
          template: notification_rule.template
        )
      end
    end
  end
end
