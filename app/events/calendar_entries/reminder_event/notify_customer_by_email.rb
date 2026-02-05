module CalendarEntries
  module ReminderEvent
    class NotifyCustomerByEmail < BaseEvent
      subscribe_to :calendar_entry_reminder_requested
      attributes :calendar_entry_id
      optional_attributes :current_user_id

      def call
        unless calendar_entry.entry_type.in?(%w[repair regular])
          return Failure("Calendar entry type is not repair or regular")
        end
        return Success("Customer already reminded") unless validate_reminded_per_email_at?

        if notification_enabled?
          yield calendar_entry_reminder_email
          calendar_entry.update(reminded_at: Time.zone.now)
          calendar_entry.update(reminded_per_email_at: Time.zone.now)
          yield create_activity(triggering_event:)
          return Success(true)
        end

        Success("Email Notification not enabled")
      end

      private

      def validate_reminded_per_email_at?
        return true if calendar_entry.reminded_per_email_at.blank?
        return true if calendar_entry.reminded_per_email_at < 2.hours.ago

        false
      end

      def create_activity(triggering_event:, activity_name: :email_sent)
        return unless calendar_entry.entry_type.in?(%w[repair regular])

        issue = calendar_entry.calendarable
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

      def calendar_entry_reminder_email
        CalendarEntryMailer.call(
          calendar_entry:,
          template: notification_rule.template
        ).deliver_now

        Success(true)
      end

      def notification_enabled?
        account.booking_settings.booking_reminder_enabled? &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :mail
        )
      end

      def triggering_event
        :calendar_entry_reminder_requested
      end

      def account
        calendar_entry.account
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end
    end
  end
end
