module CalendarEntries
  class ReminderTransaction < BaseTransaction
    attributes :calendar_entry_id

    def call
      calendar_entry = CalendarEntry.find(calendar_entry_id)

      result = calendar_entry.with_lock do
        ActiveRecord::Base.transaction do
          yield reminder.call(calendar_entry:)
        end
      end
      Success(result)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for calendar_entry #{calendar_entry_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def reminder = CalendarEntries::ReminderOperation
  end
end
