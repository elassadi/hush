module Users
  class CreateApiTokenOperation < BaseOperation
    attributes :user

    def call
      result = create_api_token
      user = result.success

      if result.success?
        Event.broadcast(:api_token_created, api_token_id: user.api_token.id) if user.api_token
        return Success(user)
      end
      Failure(result.failure)
    end

    private

    def create_api_token
      yield validate_statuses
      user.api_token&.status_deleted!
      user.api_tokens.create!(status: :active, account: user.account)
      user.reload
      Success(user)
    end

    def validate_statuses
      Success(true)
    end
  end
end
