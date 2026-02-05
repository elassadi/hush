module Customers
  class UpdateOperation < BaseOperation
    attributes :attributes, :customer
    optional_attributes :skip_address

    def call
      result = update_customer
      customer = result.success
      if result.success?
        # Event.broadcast(:customer_activated, customer_id: customer.id) if customer.status_active?
        return Success(customer)
      end

      Failure(result.failure)
    end

    private

    def update_customer
      customer.update(customer_attributes)

      return Failure(customer.errors) unless customer.valid?

      return Success(customer) if skip_address

      yield update_or_create_address

      Success(customer)
    end

    def update_or_create_address
      address = customer.primary_address
      if address.blank?
        address = customer.addresses.create(address_attributes)
      else
        address.update(address_attributes)
      end

      return Failure(address.errors) unless address.valid?

      Success(address)
    end

    def customer_attributes
      attributes.with_indifferent_access.slice(
        *%w[salutation first_name last_name company_name email
            phone_number mobile_number merchant_id
            street house_number city country post_code]
      ).merge(
        skip_address_validation: skip_address
      )
    end

    def address_attributes
      attributes.with_indifferent_access.slice(*%w[street house_number city country post_code])
    end
  end
end
