module Accounts
  class DisableOperation < BaseOperation
    attributes :account

    def call
      result = disable_account
      account = result.success
      if result.success?
        Event.broadcast(:account_disabled, account_id: account.id) if account.status_active?
        return Success(account)
      end
      Failure(result.failure)
    end

    private

    def disable_account
      yield validate_statuses

      account.status_disabled!
      # account.client.status_active!

      # yield some_other_methods

      Success(account)
    end

    def validate_statuses
      unless account.status_active? || account.status_pending_verification?
        return Failure("#{self.class} invalid_status Must be active or pending account_id: #{account.id} ")
      end

      Success(true)
    end
  end
end
