module Accounts
  class ActivateOperation < BaseOperation
    attributes :account

    def call
      result = activate_account
      account = result.success
      if result.success?
        Event.broadcast(:account_activated, account_id: account.id) if account.status_active?
        return Success(account)
      end
      Failure(result.failure)
    end

    private

    def activate_account
      yield validate_statuses
      yield update_user_role

      account.status_active!

      # yield some_other_methods

      Success(account)
    end

    def update_user_role
      role_name = {
        free: :free_account_admin,
        basic: :trail_basic_account_admin,
        advanced: :trail_basic_account_admin
      }[account.plan.to_sym]

      account.user.update!(role: account.roles.find_by(name: role_name))

      Success(true)
    end

    def validate_statuses
      # unless account.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved account_id: #{account.id} ")
      # end

      Success(true)
    end
  end
end
