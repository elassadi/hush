module Issues
  class CancelOperation < BaseOperation
    attributes :issue

    def call
      result = cancel

      result.success? ? Success(issue) : Failure(result.failure)
    end

    private

    def cancel
      yield destroy_stock_reservations
      yield create_notification
      Success(true)
    end

    def destroy_stock_reservations
      issue.issue_entries.each do |entry|
        next unless entry.stock_reservation

        IssueEntries::DestroyStockReservationOperation.call(stock_reservation: entry.stock_reservation)
      end

      Success(true)
    end

    def create_notification
      Notification.create!(
        account: issue.account,
        receiver: issue.owner,
        sender: User.system_user,
        title: "Issue #{issue.uuid} has been cancelled",
        action_path: "resources_issue_path",
        action_params: { id: issue.id }
      )
      Success(true)
    end
  end
end
