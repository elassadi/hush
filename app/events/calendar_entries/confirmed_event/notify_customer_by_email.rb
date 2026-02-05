module CalendarEntries
  module ConfirmedEvent
    class NotifyCustomerByEmail < BaseEvent
      subscribe_to :calendar_entry_confirmed
      attributes :calendar_entry_id
      optional_attributes :notify_customer, :current_user_id

      def call
        if notification_enabled?
          yield calendar_entry_confirmed_email
          yield create_activity(triggering_event:)
          destroy_ics_document
          return Success(true)
        end

        Success("Notification not enabled")
      end

      private

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

      def destroy_ics_document
        ics_document.delete
      end

      def calendar_entry_confirmed_email
        CalendarEntryMailer.call(
          calendar_entry:,
          template: notification_rule.template,
          ics_document:
        ).deliver_now

        Success(true)
      end

      def ics_document
        @ics_document ||= calendar_entry.create_ics_document
      end

      def notification_enabled?
        notify_customer &&
          notification_rule&.status_active?
      end

      def notification_rule
        @notification_rule ||= ApplicationSetting.customer_notification_for(
          trigger: triggering_event,
          channel: :mail
        )
      end

      def triggering_event
        :calendar_entry_confirmed
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end
    end
  end
end
