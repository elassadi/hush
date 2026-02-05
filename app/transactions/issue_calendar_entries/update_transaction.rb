module IssueCalendarEntries
  class UpdateTransaction < BaseTransaction
    attributes :calendar_entry_id, :attributes

    def call
      calendar_entry = CalendarEntry.find(calendar_entry_id)
      ActiveRecord::Base.transaction do
        yield update_operation.call(calendar_entry:, **attributes)
      end
      Success(calendar_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed to create IssueCalendarEntry with error: #{e.result.failure}"
      )
      raise
    end

    private

    def update_operation = IssueCalendarEntries::UpdateOperation
  end
end
