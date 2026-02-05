module Comments
  module CreatedEvent
    class NotifyWatchers < BaseEvent
      subscribe_to :comment_created, prio: 10
      attributes :comment_id

      def call
        notify_watchers

        Success(true)
      end

      private

      def notify_watchers
        return unless commentable.respond_to?(:watchers)

        commentable.watchers.each do |watcher|
          next if watcher == comment.author

          create_notification(comment.author, watcher)
        end

        Success(true)
      end

      def create_notification(author, watcher)
        Notification.create!(
          account:,
          receiver: watcher,
          sender: User.system_user,
          title: I18n.t(:title, scope: :"notifications.#{commentable.class.to_s.underscore}.comment",
                                author: author.name,
                                uuid: commentable.uuid),
          # action_link: "/dashboards/cockpit"
          action_path: "resources_#{commentable.class.to_s.underscore}_path",
          action_params: { id: commentable.id, focus_comment: comment.id }
        )

        Success(true)
      end

      def account
        @account ||= comment.account
      end

      def comment
        @comment ||= Comment.find(comment_id)
      end

      def commentable
        comment.commentable
      end
    end
  end
end
