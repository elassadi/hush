module Accounts
  module ActivatedEvent
    class NotifyUserByEmail < BaseEvent
      subscribe_to :account_activated, prio: 10
      attributes :account_id

      def call
        send_email if account.status_active?

        Success(true)
      end

      private

      def send_email
        UserMailer.activation_email(account).deliver_now

        Success(true)
      end

      def account
        @account ||= Account.find(account_id)
      end
    end
  end
end
