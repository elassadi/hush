module Users
  class ActivateOperation < BaseOperation
    attributes :user

    def call
      result = activate_user
      user = result.success
      if result.success?
        Event.broadcast(:user_activated, user_id: user.id) if user.status_active?
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def activate_user
      yield validate_statuses
      user.status_active!

      Success(user)
    end

    def validate_statuses
      Success(true)
    end
  end
end
