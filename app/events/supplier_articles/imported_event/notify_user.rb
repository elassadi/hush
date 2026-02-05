module SupplierArticles
  module ImportedEvent
    class NotifyUser < BaseEvent
      subscribe_to :supplier_articles_imported
      attributes :document_id, :user_id

      def call
        create_notification

        Success(true)
      end

      private

      def create_notification
        Notification.create!(
          account: user.account,
          receiver: user,
          sender: User.system_user,
          title: "Import der Daten ist abgeschlossen",
          metadata: { body: "Ihre Daten sind erfolgreich importiert worden" }
        )

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
