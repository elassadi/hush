module CalendarEntries
  class CancelOperation < BaseOperation
    attributes :calendar_entry, :notify_customer

    def call
      result = cancel_calendar_entry
      calendar_entry = result.success
      if result.success?
        if calendar_entry.status_canceld?
          Event.broadcast(:calendar_entry_canceld, calendar_entry_id: calendar_entry.id, notify_customer:)
        end
        return Success(calendar_entry)
      end
      Failure(result.failure)
    end

    private

    def cancel_calendar_entry
      yield validate_statuses

      calendar_entry.status_canceld!

      Success(calendar_entry)
    end

    def validate_statuses
      if calendar_entry.status_done? || calendar_entry.status_canceld?
        return Failure("#{self.class} invalid_status Must be open or in_progress id: #{calendar_entry.id} ")
      end

      Success(true)
    end
  end
end
