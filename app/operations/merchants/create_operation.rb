module Merchants
  class CreateOperation < BaseOperation
    attributes :company_name, :account_id, :first_name, :last_name, :master, :email
    optional_attributes :accounting_email

    def call
      result = create_merchant
      merchant = result.success
      if result.success?
        Event.broadcast(:merchant_created, merchant_id: merchant.id)
        return Success(merchant)
      end
      Failure(result.failure)
    end

    private

    def create_merchant
      yield validate_statuses

      merchant = Merchant.create(
        company_name:,
        account_id:,
        accounting_email: accounting_email || email,
        first_name:, last_name:,
        email:,
        master:,
        affiliate_type: master ? :master : :partner
      )

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
