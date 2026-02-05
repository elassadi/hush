module Users
  module LoggedInEvent
    class CompleteOnboardingNotification < BaseEvent
      subscribe_to :__user_logged_in
      attributes :user_id

      def call
        send_notification unless Current.user.account.completed_onboarding?
        Success(true)
      end

      private

      def send_notification
        Notification.create!(
          account:,
          receiver: user,
          sender: User.system_user,
          title: I18n.t('helpers.on_boarding.master_address_missing.title'),
          action_path: "resources_merchant_path",
          action_params: { id: account.merchant.id }
        )

        Success(true)
      end

      def account
        @account ||= user.account
      end

      def user
        User.find(user_id)
      end
    end
  end
end
