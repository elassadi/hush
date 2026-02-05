module PurchaseOrders
  class StockOrderOperation < BaseOperation
    attributes :purchase_order

    def call
      result = stock_order
      if result.success?
        # Event.broadcast(:purchase_order_created, purchase_order_id: purchase_order.id) if @new_record
        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def stock_order
      yield validate_statuses
      yield stock_purchase_order_entries

      Success(true)
    end

    def validate_statuses
      unless purchase_order.status_category_in_progress?
        return Failure("#{self.class} failed: Purchase order is not in progress status id: #{purchase_order.id}")
      end

      Success(true)
    end

    def stock_purchase_order_entries
      purchase_order.purchase_order_entries.each do |entry|
        StockMovement.create!(
          action: :stock_in,
          action_type: :stock_with_referenz,
          originator: entry,
          owner: User.system_user,
          stock_location: stock_area(entry).stock_location,
          stock_area: stock_area(entry),
          article: entry.article,
          qty: entry.qty
        )
      end
      Success(true)
    end

    def stock_area(entry)
      item = StockItem.by_account.where(article_id: entry.article.id).order(in_stock: :desc).first
      if item
        item.stock_area
      else
        location = StockLocation.by_account.primary
        location.stock_areas.first
      end
    end
  end
end
