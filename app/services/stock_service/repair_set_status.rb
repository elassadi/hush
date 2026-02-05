module StockService
  class RepairSetStatus < Status
    def stock_status(issue = nil)
      return @stock_status if @stock_status.present?

      entries = if issue
                  issue.issue_entries_by_set(originator)
                else
                  originator.repair_set_entries
                end
      stock_index = entries.map do |entry|
        STOCK_STATUS.index(entry.stock_status)
      end.max

      return STOCK_STATUS_UNKNOWN if stock_index.nil?

      @stock_status = STOCK_STATUS[stock_index]
    end
  end
end
