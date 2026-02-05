module Merchants
  class CreateTransaction < BaseTransaction
    attributes :merchant_attributes

    def call
      merchant = ActiveRecord::Base.transaction do
        yield create_merchant.call(**merchant_attributes)
      end
      Success(merchant)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for merchant #{merchant_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def create_merchant = Merchants::CreateOperation
  end
end
