module Users
  class LoginAsOperation < BaseOperation
    attributes :user

    def call
      result = login_as_user
      user = result.success
      if result.success?
        Event.broadcast(:user_login_as, user_id: user.id) if user.status_active?
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def login_as_user
      yield validate_statuses

      Success(user)
    end

    def validate_statuses
      unless user.active_for_authentication?
        return Failure("#{self.class} invalid_status Must be active user_id: #{user.id} ")
      end

      Success(true)
    end
  end
end
