module PurchaseOrders
  class ShouldDestroyTransaction < BaseTransaction
    attributes :stock_reservation_hsh

    def call
      result = ActiveRecord::Base.transaction do
        yield should_destroy.call(stock_reservation:)
      end
      Success(result)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for stock_reservation #{stock_reservation_hsh} failed with #{e.result.failure}"
      )
      raise
    end

    def stock_reservation
      @stock_reservation ||= StockReservation.new(stock_reservation_hsh)
    end

    private

    def should_destroy = PurchaseOrders::ShouldDestroyOperation
  end
end
