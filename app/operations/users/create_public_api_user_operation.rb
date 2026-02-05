module Users
  class CreatePublicApiUserOperation < BaseOperation
    attributes :account

    def call
      result = create_public_api_user
      user = result.success

      if result.success?
        Event.broadcast(:public_api_user_created, user_id: user.id)
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def create_public_api_user
      yield validate_statuses
      user = yield persist_public_api_user
      yield create_public_api_token(user)

      Success(user)
    end

    def persist_public_api_user
      Users::CreateOperation.call(
        account:,
        email: "public-api-user-#{account.uuid}@hush-haarentfernung.de",
        role_name: :public_api,
        password: SecureRandom.hex(8),
        name: :public_api,
        api_only: true,
        skip_verification: true
      )
    end

    def create_public_api_token(public_user)
      Users::CreateApiTokenOperation.call(user: public_user)
    end

    def validate_statuses
      return Failure("#{self.class} Public user exists alread #{account.id} ") if account.public_user

      Success(true)
    end
  end
end
