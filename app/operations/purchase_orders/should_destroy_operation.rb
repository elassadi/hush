module PurchaseOrders
  class ShouldDestroyOperation < BaseOperation
    attributes :stock_reservation

    def call
      result = should_destroy
      if result.success?
        # Event.broadcast(:purchase_order_created, purchase_order_id: purchase_order.id) if @new_record
        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def should_destroy
      return Success(true) if purchase_order.blank?

      return detach_purchase_order_entry unless purchase_order.status_category_open?

      yield update_or_destroy_purchase_order_entry

      purchase_order.destroy! if purchase_order.reload.purchase_order_entries.blank?

      Success(purchase_order)
    end

    def detach_purchase_order_entry
      entry = purchase_order.purchase_order_entries.find_by(
        article: stock_reservation.article,
        originator: stock_reservation,
        account: stock_reservation.account
      )

      return Success(true) if entry.blank?

      final_qty = entry.qty - stock_reservation.qty

      if final_qty <= 0
        entry.stock_reservation = nil
        entry.save!
      end
      Success(true)
    end

    def update_or_destroy_purchase_order_entry
      entry = purchase_order.purchase_order_entries.find_by(
        article: stock_reservation.article,
        originator: stock_reservation,
        account: stock_reservation.account
      )

      return Success(true) if entry.blank?

      final_qty = entry.qty - stock_reservation.qty

      if final_qty <= 0
        entry.destroy!
      else
        entry.update!(qty: final_qty)
      end
      Success(true)
    end

    def purchase_order
      @purchase_order ||= PurchaseOrder.joins(
        "INNER JOIN purchase_order_entries ON purchase_order_entries.purchase_order_id = purchase_orders.id"
      ).where(
        purchase_order_entries: { originator: stock_reservation },
        supplier: stock_reservation.article.supplier,
        account: stock_reservation.account
      ).distinct.first
    end
    # def purchase_order
    #   @purchase_order ||= PurchaseOrder.find_by(
    #     supplier: stock_reservation.article.supplier,
    #     account: stock_reservation.account
    #   )
    # end
  end
end
