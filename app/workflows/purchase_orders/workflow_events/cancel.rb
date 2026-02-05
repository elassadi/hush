module PurchaseOrders
  module WorkflowEvents
    class Cancel < ::RecloudCore::DryBase
      attributes :resource
      def call
        result = process_event
        if result.success?
          # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
          return Success(true)
        end

        Failure(result.failure)
      end

      def process_event
        # Notification.create!(
        #   account: issue.account,
        #   receiver: issue.owner,
        #   sender: User.system_user,
        #   title: "Issue #{issue.uuid} has been cancelled",
        #   action_path: "resources_issue_path",
        #   action_params: { id: issue.id }
        # )
        Success(true)
      end
    end
  end
end
