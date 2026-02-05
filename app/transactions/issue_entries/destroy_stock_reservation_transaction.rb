module IssueEntries
  class DestroyStockReservationTransaction < BaseTransaction
    attributes :stock_reservation_id

    def call
      stock_reservation = StockReservation.find(stock_reservation_id)

      ActiveRecord::Base.transaction do
        yield destroy_stock_reservation.call(stock_reservation:)
      end
      Success(stock_reservation)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for stock_reservation #{stock_reservation_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def destroy_stock_reservation = IssueEntries::DestroyStockReservationOperation
  end
end
