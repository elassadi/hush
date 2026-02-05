module StockService
  class IssueStatus < Status
    def stock_status
      return @stock_status if @stock_status.present?

      issue = originator

      entries = issue.issue_entries.not_category_rabatt
      stock_index = entries.map do |entry|
        STOCK_STATUS.index(entry.stock_status)
      end.max

      return STOCK_STATUS_UNKNOWN if stock_index.nil?

      @stock_status = STOCK_STATUS[stock_index]
    end

    class << self
    end
  end
end
