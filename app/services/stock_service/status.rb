module StockService
  class Status
    attr_accessor :originator

    STOCK_STATUS = [
      STOCK_STATUS_AVAILABLE = "available".freeze,
      STOCK_STATUS_ORDERED = "ordered".freeze,
      STOCK_STATUS_DELIVERED = "delivered".freeze,
      STOCK_STATUS_WILL_BE_ORDERED = "will_be_ordered".freeze,
      STOCK_STATUS_CAN_BE_ORDERED = "can_be_ordered".freeze,
      STOCK_STATUS_SHORTLY_AVAILABLE = "shortly_available".freeze,
      STOCK_STATUS_UPON_ORDER = "upon_order".freeze,
      STOCK_STATUS_NOT_AVAILABLE = "unavailable".freeze,
      STOCK_STATUS_UNKNOWN = "unknown".freeze
    ].freeze

    def initialize(originator)
      @originator = originator
      @originator.reload if Rails.env.test?
    end

    def stock_status
      raise Class.new(StandardError), " StockStatus Not implemented"
    end

    class << self
      def stock_status(entry)
        stock_service(entry).stock_status
      end

      def stock_service(entry)
        stock_service_instance(entry)
      end

      def stock_service_instance(entry)
        klass = {
          "Issue" => ::StockService::IssueStatus,
          "IssueEntry" => ::StockService::IssueEntryStatus,
          "RepairSet" => ::StockService::RepairSetStatus,
          "RepairSetEntry" => ::StockService::RepairSetEntryStatus
        }.fetch(entry.class.name)

        return raise Class.new(StandardError), "NOT implemented" if klass.nil?

        klass.new(entry)
      end
    end
  end
end
