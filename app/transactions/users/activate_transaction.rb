module Users
  class ActivateTransaction < BaseTransaction
    attributes :user_id

    def call
      user = User.find(user_id)
      ActiveRecord::Base.transaction do
        yield activate_user.call(user:)
      end
      Success(user)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for user #{user_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def activate_user = Users::ActivateOperation
  end
end
