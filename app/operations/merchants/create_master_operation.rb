module Merchants
  class CreateMasterOperation < BaseOperation
    attributes :merchant

    def call
      result = create_master_merchant
      merchant = result.success
      if result.success?
        Event.broadcast(:merchant_created, merchant_id: merchant.id)

        return Success(merchant)
      end
      Failure(result.failure)
    end

    private

    def create_master_merchant
      yield validate_statuses

      merchant.save
      return Success(merchant) if merchant.valid?

      Failure(merchant)
    end

    def validate_statuses
      # unless merchant.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved merchant_id: #{merchant.id} ")
      # end

      Success(true)
    end
  end
end
