# frozen_string_literal: true

module Issues
  class UnlockJob < ApplicationJob
    def perform
      locked_issues.find_in_batches(batch_size: 10) do |batch|
        batch.map! do  |issue|
          Current.user = issue.account.user
          Issues::UnlockTransaction.call(issue_id: issue.id, expired_unlock: true)
        end
      end
    end

    def locked_issues
      Issue.locked.where("
        updated_at + INTERVAL ? SECOND < ?", Issue::DEFAULT_LOCK_EXPIRE_AFTER.seconds,
                         Time.zone.now)
    end
  end
end
