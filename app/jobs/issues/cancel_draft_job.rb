# frozen_string_literal: true

module Issues
  class CancelDraftJob < ApplicationJob
    DRAFT_RETENTION_PERIOD = 30.days
    def perform
      draf_issues.find_in_batches(batch_size: 10) do |batch|
        batch.map! do  |issue|
          Current.user = issue.account.user
          Issues::TransitionToTransaction.call(issue_id: issue.id, event: :cancel,
                                               comment: I18n.t('actions.issues.cancel_action.cancel_draft_job_comment'),
                                               owner: Current.user)
        end
      end
    end

    def draf_issues
      @draf_issues ||= Issue.where(status: :draft, updated_at: ..DRAFT_RETENTION_PERIOD.ago)
    end
  end
end
