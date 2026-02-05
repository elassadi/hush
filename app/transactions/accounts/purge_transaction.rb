module Accounts
  class PurgeTransaction < BaseTransaction
    attributes :account_id

    def call
      account = Account.find(account_id)
      ActiveRecord::Base.transaction do
        yield purge_account.call(account:)
      end
      Success(account)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for account #{account_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def purge_account = Accounts::PurgeOperation
  end
end
