module CalendarEntries
  module CreatedEvent
    class NotifyAccountByTelegram < BaseEvent
      subscribe_to :calendar_entry_created
      attributes :calendar_entry_id

      def call
        return Success("Skipped, its a backend created entry") unless source_api?

        yield telegram_message

        Success(true)
      end

      private

      def source_api?
        calendar_entry.source == "api"
      end

      def telegram_message
        message = build_message
        result = Telegram::Sender.call(text: message)
        return result if result.failure?

        Success(true)
      end

      def build_message
        <<~HTML
          🔔 <b>Neue Terminanfrage</b>

          Eine neue Terminanfrage ist eingetroffen.

          <b>📅 Wann:</b>
          #{formatted_start_at}

          <b>👤 Kunde:</b>
          #{customer_name}
          #{customer_phone_line}

          Bitte im System prüfen und bestätigen.
        HTML
      end

      def formatted_start_at
        I18n.l(calendar_entry.start_at)
      end

      def customer_name
        customer&.name || "Unbekannt"
      end

      def customer_phone_line
        return "" unless customer&.mobile_number.present?

        customer.mobile_number
      end



      def customer
        @customer ||= begin
          calendar_entry.customer ||
            (calendar_entry.entry_type.in?(%w[repair regular]) ? issue&.customer : nil)
        end
      end

      def issue
        @issue ||= calendar_entry.calendarable if calendar_entry.calendarable_type == "Issue"
      end

      def calendar_entry
        @calendar_entry ||= CalendarEntry.by_account.find(calendar_entry_id)
      end
    end
  end
end
