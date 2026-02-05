module IssueCalendarEntries
  module Api
    class CreateTransaction < BaseTransaction
      attributes :params

      def call
        calendar_entry = ActiveRecord::Base.transaction do
          yield create_operation.call(params:)
        end
        Success(calendar_entry)
      rescue Dry::Monads::Do::Halt => e
        ErrorTracking.capture_message(
          "#{self.class.name} failed to create IssueCalendarEntry with error: #{e.result.failure.inspect}"
        )
        raise
      end

      private

      def create_operation = IssueCalendarEntries::Api::CreateOperation
    end
  end
end
