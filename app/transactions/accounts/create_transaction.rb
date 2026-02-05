module Accounts
  class CreateTransaction < BaseTransaction
    attributes :account_attributes
    def call
      account = ActiveRecord::Base.transaction do
        yield create_account.call(**account_attributes)
      end
      Success(account)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for account failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_account = Accounts::CreateOperation
  end
end
