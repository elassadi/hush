module Users
  module ActivatedEvent
    class SendNotificationEmail < BaseEvent
      subscribe_to :user_activated__

      attributes :user_id

      def call
        process_user_activated
      end

      private

      def process_user_activated
        ApplicationMailer.notification_mail("User #{user.email} has beeen activated").deliver

        Success(true)
      end

      def user
        User.find(user_id)
      end
    end
  end
end
