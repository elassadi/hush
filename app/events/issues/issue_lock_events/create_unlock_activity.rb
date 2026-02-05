module Issues
  module IssueLockEvents
    class CreateUnlockActivity < BaseIssueEvent
      subscribe_to :issue_unlocked
      attributes :issue_id
      optional_attributes :current_user_id

      def call
        create_activity
      end

      private

      def create_activity
        activity = yield Activities::CreateTransaction.call(
          activityable: issue,
          activity_name:,
          activity_data:,
          owner_id: current_user_id
        )
        Success(activity)
      end

      def issue
        @issue ||= Issue.by_account.find(issue_id)
      end

      def activity_name = "issue_unlocked"

      def activity_data
        {
          from: issue.status,
          to: issue.status,
          triggering_event: activity_name,
          event_args: {}
        }
      end
    end
  end
end
