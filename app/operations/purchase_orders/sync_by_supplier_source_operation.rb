module PurchaseOrders
  class SyncBySupplierSourceOperation < BaseOperation
    attributes :supplier_source

    def call
      result = sync_by_supplier_supplier_source_supplier_source
      supplier_source = result.success
      return Success(supplier_source) if result.success?

      Failure(result.failure)
    end

    private

    def sync_by_supplier_supplier_source_supplier_source
      yield validate_statuses
      yield update_existing_purchase_orders
      yield create_new_purchase_orders

      Success(supplier_source)
    end

    def update_existing_purchase_orders
      purchase_order_entries = []
      PurchaseOrder.status_category_open
                   .where(account_id: @supplier_source.account_id)
                   .includes(:purchase_order_entries).find_each do |purchase_order|
        purchase_order_entries << purchase_order.purchase_order_entries.select do |entry|
          entry.article_id == @supplier_source.article_id
        end
      end
      purchase_order_entries.flatten!
      purchase_order_entries.compact!

      purchase_order_entries.each do |entry|
        entry.destroy!
        entry.purchase_order.destroy! if entry.purchase_order.reload.purchase_order_entries.blank?
      end

      # Update existing purchase orders
      purchase_order_entries.each do |entry| # rubocop:todo Style/CombinableLoops
        yield PurchaseOrders::CreateOrUpdateOperation.call(stock_reservation: entry.stock_reservation)
      end
      Success(true)
    end

    def create_new_purchase_orders
      IssueEntry.where(article_id: @supplier_source.article_id, account_id: @supplier_source.account_id)
                .joins(:issue, :stock_reservation)
                .left_outer_joins(stock_reservation: :purchase_order_entry)
                .where(issue: { status_category: %w[open in_progress] })
                .where(purchase_order_entries: { purchase_order_id: nil }).find_each do |entry|
        yield PurchaseOrders::CreateOrUpdateOperation.call(stock_reservation: entry.stock_reservation)
      end
      Success(true)
    end

    def validate_statuses
      Success(true)
    end
  end
end
