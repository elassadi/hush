module Accounts
  module CreatedEvent
    class NotifyAdminByEmail < BaseEvent
      subscribe_to :account_created
      attributes :account_id

      def call
        send_email

        Success(true)
      end

      private

      def send_email
        AdminMailer.new_account_mail(account).deliver_now

        Success(true)
      end

      def account
        @account ||= Account.find(account_id)
      end
    end
  end
end
