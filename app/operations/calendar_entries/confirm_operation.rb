module CalendarEntries
  class ConfirmOperation < BaseOperation
    attributes :calendar_entry, :notify_customer

    def call
      result = confirm_calendar_entry
      calendar_entry = result.success
      if result.success?
        Event.broadcast(:calendar_entry_confirmed, calendar_entry_id: calendar_entry.id, notify_customer:)
        return Success(calendar_entry)
      end

      Failure(result.failure)
    end

    private

    def confirm_calendar_entry
      yield validate_statuses
      yield reset_owner_if_api

      calendar_entry.confirmed_at = Time.zone.now

      return Failure(calendar_entry.errors.full_messages) unless calendar_entry.valid? && calendar_entry.save

      Success(calendar_entry)
    end

    def reset_owner_if_api
      return Success(true) unless calendar_entry.source_api?

      calendar_entry.owner = Current.user

      if issue.source_api? && issue.owner.api?
        issue.owner = Current.user
        issue.save!
      end

      Success(true)
    end

    def issue
      @issue ||= calendar_entry.calendarable
    end

    def validate_statuses
      Success(true)
    end
  end
end
