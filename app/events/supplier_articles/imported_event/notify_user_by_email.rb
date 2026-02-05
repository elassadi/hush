module SupplierArticles
  module ImportedEvent
    class NotifyUserByEmail < BaseEvent
      subscribe_to :supplier_articles_imported
      attributes :document_id, :user_id

      def call
        send_email

        Success(true)
      end

      private

      def send_email
        ImportMailer.imported_email(document:, user:).deliver_now

        Success(true)
      end

      def document
        @document ||= Document.find(document_id)
      end

      def user
        @user ||= User.find(user_id)
      end
    end
  end
end
