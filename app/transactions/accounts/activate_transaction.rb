module Accounts
  class ActivateTransaction < BaseTransaction
    attributes :account_id

    def call
      account = Account.find(account_id)
      ActiveRecord::Base.transaction do
        yield activate_account.call(account:)
      end
      Success(account)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for account #{account_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def activate_account = Accounts::ActivateOperation
  end
end
