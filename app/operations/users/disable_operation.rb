module Users
  class DisableOperation < BaseOperation
    attributes :user

    def call
      result = disable_user
      user = result.success

      if result.success?
        Event.broadcast(:user_disabled, user_id: user.id) if user.status_disabled?
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def disable_user
      yield validate_statuses
      user.status_disabled!

      Success(user)
    end

    def validate_statuses
      return Failure("You can't disable your account ") if disabling_myself?

      return Failure("You are not authorized") unless authorized?

      Success(true)
    end

    def disabling_myself?
      Current.user == user
    end

    def authorized?
      return true unless user.admin?

      Current.user.admin?
    end
  end
end
