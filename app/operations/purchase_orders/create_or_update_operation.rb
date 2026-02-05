module PurchaseOrders
  class CreateOrUpdateOperation < BaseOperation
    attributes :stock_reservation
    attr_reader :new_record

    def call
      result = create_or_update_purchase_order
      purchase_order = result.success
      if result.success?
        # Event.broadcast(:purchase_order_created, purchase_order_id: purchase_order.id) if @new_record
        return Success(purchase_order)
      end

      Failure(result.failure)
    end

    private

    def create_or_update_purchase_order
      if stock_available?
        yield PurchaseOrders::ShouldDestroyOperation.call(stock_reservation:)
        return Success(true)
      end

      return Success(true) if should_be_skipped?

      purchase_order = yield update_or_create_purchase_order

      Success(purchase_order)
    end

    def should_be_skipped?
      no_supplier_source? ||
        temporary_reservation? ||
        issue_status_not_in_progress? ||
        stock_reservation.status_reserved?
    end

    def update_or_create_purchase_order
      article = stock_reservation.article.reload

      purchase_order = PurchaseOrder.status_category_open.find_or_create_by!(
        supplier: article.supplier,
        account: stock_reservation.account,
        merchant: Current.user.merchant
      ) do |_record|
        @new_record = true
      end

      entry = purchase_order.purchase_order_entries.find_or_initialize_by(**purchase_order_entry_base_attributes)
      entry.update!(
        price: stock_reservation.article.supplier_source.purchase_price,
        qty: purchase_order_entry_qty
      )

      Success(purchase_order)
    end

    def purchase_order_entry_base_attributes
      {
        article: stock_reservation.article,
        originator: stock_reservation,
        account: stock_reservation.account
      }
    end

    def purchase_order_entry_qty
      # stock_reservation.qty - stock_reservation.article.stock.in_stock
      # stock_reservation.qty
      [
        stock_reservation.article.stock.in_stock_available * -1,
        stock_reservation.qty
      ].min
    end

    def stock_available?
      article = stock_reservation.article.reload
      article.stock.in_stock_available >= 0
    end

    def issue_status_not_in_progress?
      !stock_reservation.issue.status_category_in_progress?
    end

    def no_supplier_source?
      stock_reservation.article.supplier_source.blank?
    end

    def temporary_reservation?
      stock_reservation.temporary?
    end
  end
end
