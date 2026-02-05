module IssueEntries
  class UpdatePriceTransaction < BaseTransaction
    attributes :issue_id, :issue_entry_ids, :user_given_set_price
    def call
      issue_entries = ActiveRecord::Base.transaction do
        yield update_repair_set.call(issue_id:, issue_entry_ids:, user_given_set_price:)
      end
      Success(issue_entries)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed  to update repair set with #{e.result.failure}"
      )
      raise
    end

    private

    def update_repair_set = IssueEntries::UpdatePriceOperation
  end
end
