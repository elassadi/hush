module CalendarEntries
  class ReminderOperation < BaseOperation
    attributes :calendar_entry

    def call
      result = check_reminder
      if result.success?
        if result.success != :no_reminder_due
          Event.broadcast(:calendar_entry_reminder_requested, calendar_entry_id: calendar_entry.id,
                                                              frequency: result.success)
        end
        return Success({ frequency: result.success })
      end

      Failure(result.failure)
    end

    private

    def check_reminder
      yield validate_frequency
      yield validate_if_reminder_enabled

      frequency = find_due_reminder_frequency
      return Success(frequency) if frequency

      Success(:no_reminder_due)
    end

    def find_due_reminder_frequency
      reminder_intervals = {
        "one_hour_before" => 1.hour,
        "one_day_before" => 1.day
      }

      reminder_margins = {
        "one_hour_before" => 15.minutes,
        "one_day_before" => 2.hours
      }

      reminder_intervals.each do |frequency, interval|
        next unless frequencies.include?(frequency)

        time_to_remind = calendar_entry.start_at - interval
        if (calendar_entry.reminded_at.nil? || calendar_entry.reminded_at < time_to_remind) &&
           (Time.zone.now >= time_to_remind && Time.zone.now <= time_to_remind + reminder_margins[frequency])
          return frequency
        end
      end

      false
    end

    def account
      calendar_entry.account
    end

    def frequencies
      account.booking_settings.booking_reminder_frequency
    end

    def validate_frequency
      return Failure("Frequency is not valid") if frequencies.blank?

      Success(true)
    end

    def validate_if_reminder_enabled
      return Failure("Reminder is not enabled") unless account.booking_settings.booking_reminder_enabled?

      Success(true)
    end
  end
end
