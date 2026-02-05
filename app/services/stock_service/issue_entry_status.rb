module StockService
  class IssueEntryStatus < Status
    delegate :stock_reservation, :article, :supplier_source, :issue, to: :originator

    def stock_able?
      return false if originator.category_text?

      article&.article_type_basic?
    end

    def stock_status(_ignore = nil)
      return STOCK_STATUS_AVAILABLE if stock_is_available?
      return STOCK_STATUS_AVAILABLE if reassignable_stock_available?

      return supplier_stock if issue.status_draft? && supplier_stock != STOCK_STATUS_AVAILABLE

      stock_status_from_order
    end

    def supplier_stock
      return STOCK_STATUS_AVAILABLE unless stock_able?
      return STOCK_STATUS_UNKNOWN if article.supplier_source.blank?

      article.supplier_source.stock_status
    end

    def stock_is_available?
      return true unless stock_able?
      return true if stock_reservation&.reserved_at?

      false
    end

    # rubocop:todo Metrics/PerceivedComplexity
    def reassignable_stock_available? # rubocop:todo Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return false if stock_reservation.blank?
      return false unless issue.status_category_open?
      return false unless article.stock.in_stock > 0

      qty = article.stock_reservations.status_reserved.where(fulfilled_at: nil).sum do |reservation|
        if reservation.issue.request_approval_at.blank? && reservation.issue.status_category_open? &&
           reservation.issue != issue
          reservation.qty
        else
          0
        end
      end

      qty >= stock_reservation.qty
    end
    # rubocop:enable Metrics/PerceivedComplexity

    private

    def stock_status_from_order
      return STOCK_STATUS_WILL_BE_ORDERED if purchase_order_will_be_ordered?
      return STOCK_STATUS_ORDERED if purchase_order_ordered?
      return STOCK_STATUS_DELIVERED if purchase_order_delivered?
      return STOCK_STATUS_CAN_BE_ORDERED if purchase_order_can_be_ordered?

      STOCK_STATUS_UNKNOWN
    end

    def purchase_order_can_be_ordered?
      article.supplier_source.present?
    end

    def purchase_order_will_be_ordered?
      return false if stock_reservation.blank?
      return false if stock_reservation.purchase_order.blank?

      stock_reservation.purchase_order.status_category_open?
    end

    def purchase_order_delivered?
      return false if stock_reservation.blank? || stock_reservation.purchase_order.blank?

      !stock_reservation.purchase_order.status_category_open? && stock_reservation.purchase_order.status == "delivered"
    end

    def purchase_order_ordered?
      return false if stock_reservation.blank? || stock_reservation.purchase_order.blank?

      !stock_reservation.purchase_order.status_category_open? && stock_reservation.purchase_order.status == "ordered"
    end

    class << self
    end
  end
end
