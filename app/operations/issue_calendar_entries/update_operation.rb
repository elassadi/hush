module IssueCalendarEntries
  class UpdateOperation < BaseOperation
    attributes(:calendar_entry, *%i[start_at end_at all_day])
    optional_attributes(*%i[category event_color notes notify_customer entry_type])
    attr_reader :issue_calendar_entry

    def call
      result = validate_and_update_issue_calendar_entry
      if result.success?
        issue_calendar_entry = result.success
        Event.broadcast(:calendar_entry_updated, calendar_entry_id: issue_calendar_entry.id, notify_customer:)
        return Success(issue_calendar_entry)
      end
      Failure(result.failure)
    end

    private

    def validate_and_update_issue_calendar_entry
      yield validate_statuses

      @issue_calendar_entry = yield update_issue_calendar_entry

      Success(issue_calendar_entry)
    end

    def update_issue_calendar_entry
      calendar_entry.update(
        start_at:,
        end_at:,
        category: category || calendar_entry.category,
        event_color: event_color || calendar_entry.event_color,
        notes: notes || calendar_entry.notes,
        all_day:,
        entry_type:
      )
      return Failure(calendar_entry) unless calendar_entry.valid?

      Success(calendar_entry)
    end

    def validate_statuses
      # unless quote.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved quote_id: #{quote.id} ")
      # end

      Success(true)
    end
  end
end
