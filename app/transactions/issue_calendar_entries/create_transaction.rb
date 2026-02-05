module IssueCalendarEntries
  class CreateTransaction < BaseTransaction
    attributes :attributes

    def call
      issue_calendar_entry = ActiveRecord::Base.transaction do
        yield create_operation.call(**attributes)
      end
      Success(issue_calendar_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed to create IssueCalendarEntry with error: #{e.result.failure}"
      )
      raise
    end

    private

    def create_operation = IssueCalendarEntries::CreateOperation
  end
end
