module IssueEntries
  class UpdateStockReservationTransaction < BaseTransaction
    attributes :issue_entry_id

    def call
      issue_entry = IssueEntry.find(issue_entry_id)
      ActiveRecord::Base.transaction do
        yield update_stock_reservation.call(issue_entry:)
      end
      Success(issue_entry)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue_entry #{issue_entry_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def update_stock_reservation = IssueEntries::UpdateStockReservationOperation
  end
end
