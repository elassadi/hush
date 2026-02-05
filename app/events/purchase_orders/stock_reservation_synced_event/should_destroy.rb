module PurchaseOrders
  module StockReservationSyncedEvent
    class ShouldDestroy < BaseEvent
      subscribe_to :stock_reservation_synced
      attributes :article_id, :issue_ids

      def call
        issue_ids.each do |issue_id|
          issue = Issue.by_account.find(issue_id)
          issue.issue_entries.stockable.each do |issue_entry|
            next if issue_entry.stock_reservation.status_pending?

            hsh = issue_entry.stock_reservation.attributes.to_h
            yield PurchaseOrders::ShouldDestroyTransaction.call(stock_reservation_hsh: hsh)
          end
        end
        Success(true)
      end
    end
  end
end
