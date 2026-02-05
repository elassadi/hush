module CalendarEntries
  module ReminderEvent
    class NotifyCustomerBySms < BaseEvent
      subscribe_to :calendar_entry_reminder_requested
      attributes :calendar_entry_id
      optional_attributes :current_user_id

      def call
        unless calendar_entry.entry_type.in?(%w[repair regular])
          return Failure("Calendar entry type is not repair or regular")
        end
        return Success("Customer already reminded") unless validate_reminded_per_sms_at?

        if notification_enabled?
          yield send_sms
          calendar_entry.update(reminded_at: Time.zone.now)
          calendar_entry.update(reminded_per_sms_at: Time.zone.now)
          yield create_activity(triggering_event:)
          return Success(true)
        end

        Success("Booking Reminder not enabled")
      end

      private

      def validate_reminded_per_sms_at?
        return true if calendar_entry.reminded_per_sms_at.blank?
        return true if calendar_entry.reminded_per_sms_at < 2.hours.ago

        false
      end

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
        account.booking_settings.booking_reminder_enabled? &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :sms
        )
      end

      def triggering_event
        :calendar_entry_reminder_requested
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end

      def issue
        @issue ||= calendar_entry.calendarable
      end

      def account
        calendar_entry.account
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
