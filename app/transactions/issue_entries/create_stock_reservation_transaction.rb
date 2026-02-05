module IssueEntries
  class CreateStockReservationTransaction < BaseTransaction
    attributes :issue_entry_id

    def call
      issue_entry = IssueEntry.find(issue_entry_id)
      ActiveRecord::Base.transaction do
        yield create_stock_reservation_issue_entry.call(issue_entry:)
      end
      Success(issue_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue_entry #{issue_entry_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_stock_reservation_issue_entry = IssueEntries::CreateStockReservationOperation
  end
end
