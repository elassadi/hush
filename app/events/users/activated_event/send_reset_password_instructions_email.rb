module Users
  module ActivatedEvent
    class SendResetPasswordInstructionsEmail < BaseEvent
      subscribe_to :user_created

      attributes :user_id, :send_reset_password_instructions

      def call
        return Success(true) unless send_reset_password_instructions

        process_user_created
      end

      private

      def process_user_created
        yield validate_statuses

        user.send_reset_password_instructions

        Success(true)
      end

      def user
        @user ||= User.find(user_id)
      end

      def validate_statuses
        unless user.active_for_authentication?
          return Failure("#{self.class} active_for_authentication is false for User: #{user.id} aborting!")
        end

        Success(true)
      end
    end
  end
end
