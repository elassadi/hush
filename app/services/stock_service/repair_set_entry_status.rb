module StockService
  class RepairSetEntryStatus < IssueEntryStatus
    def stock_status
      return STOCK_STATUS_AVAILABLE if stock_is_available?

      return supplier_stock if supplier_stock != STOCK_STATUS_AVAILABLE

      return STOCK_STATUS_CAN_BE_ORDERED if purchase_order_can_be_ordered?

      STOCK_STATUS_UNKNOWN
    end

    def stock_able?
      article&.article_type_basic?
    end

    def stock_is_available?
      return true unless stock_able?

      return true if originator.qty <= article.stock.in_stock_available

      false
    end
  end
end
