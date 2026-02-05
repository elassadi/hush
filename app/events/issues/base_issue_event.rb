# frozen_string_literal: true

module Issues
  class BaseIssueEvent < BaseEvent
    optional_attributes :current_user_id

    private

    def create_activity(triggering_event:, activity_name: :email_sent)
      Activities::CreateTransaction.call(
        activityable: issue,
        activity_name:,
        activity_data: {
          document_id: @document_id || nil,
          triggering_event:,
          from: @from || issue.status,
          to: @to || issue.status
        },
        owner_id: current_user_id
      )
    end
  end
end
