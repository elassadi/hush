module Users
  class CreateOperation < BaseOperation
    attributes :email, :account, :role_name, :password
    optional_attributes :name, :api_only, :skip_verification, :send_reset_password_instructions, :master

    def call
      result = create_user
      user = result.success
      if result.success?
        Event.broadcast(:user_created, user_id: user.id, send_reset_password_instructions:) if user.valid?
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def create_user
      yield validate_statuses
      user = User.create(
        password:,
        current_account: account,
        account:,
        merchant: account.merchant,
        email:,
        name: name || email,
        access_level: :account,
        role:,
        api_only:,
        confirmed_at:,
        agb: true,
        master:
      )

      return Success(user) if user.valid?

      Failure(user)
    end

    def role
      @role || account.roles.find_by(name: role_name)
    end

    def validate_statuses
      Success(true)
    end

    def confirmed_at
      return Time.zone.now if skip_verification

      nil
    end
  end
end
