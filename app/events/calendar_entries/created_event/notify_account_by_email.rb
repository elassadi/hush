module CalendarEntries
  module CreatedEvent
    class NotifyAccountByEmail < BaseEvent
      subscribe_to :calendar_entry_created
      attributes :calendar_entry_id

      def call
        return Success("Skipped, its a backend created entry") unless source_api?

        yield send_email

        Success(true)
      end

      private

      def source_api?
        calendar_entry.source == "api"
      end

      def send_email
        AccountMailer.new_calendar_entry(
          calendar_entry:
        ).deliver_now
        Success(true)
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end
    end
  end
end
