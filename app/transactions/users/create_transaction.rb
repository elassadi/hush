module Users
  class CreateTransaction < BaseTransaction
    attributes :user_attributes
    def call
      user = ActiveRecord::Base.transaction do
        yield create_user.call(**user_attributes)
      end
      Success(user)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for user failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_user = Users::CreateOperation
  end
end
