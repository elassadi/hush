module CalendarEntries
  class ConfirmTransaction < BaseTransaction
    attributes :calendar_entry_id, :notify_customer

    def call
      calendar_entry = CalendarEntry.find(calendar_entry_id)
      ActiveRecord::Base.transaction do
        yield confirm_calendar_entry.call(calendar_entry:, notify_customer:)
      end
      Success(calendar_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for calendar_entry #{calendar_entry_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def confirm_calendar_entry = CalendarEntries::ConfirmOperation
  end
end
