module Customers
  class CreateOperation < BaseOperation
    attributes :attributes
    optional_attributes :skip_address

    def call
      @skip_address = true

      result = create_customer
      customer = result.success
      if result.success?
        # Event.broadcast(:customer_activated, customer_id: customer.id) if customer.status_active?
        return Success(customer)
      end

      Failure(result.failure)
    end

    private

    def create_customer
      customer = Customer.create(customer_attributes)

      return Failure(customer.errors) unless customer.persisted?

      return Success(customer) if skip_address

      address = customer.addresses.create(address_attributes)
      address.persisted? ? Success(customer) : Failure(address.errors)
    end

    def customer_attributes
      attrs = attributes.with_indifferent_access.slice(
        *%w[salutation first_name last_name company_name email
            phone_number mobile_number street house_number city country post_code merchant_id]
      ).merge(
        skip_address_validation: skip_address
      )

      # Generate dummy email if not provided and mobile_number is present
      if attrs[:email].blank? && attrs[:mobile_number].present?
        clean_mobile = attrs[:mobile_number].to_s.gsub(/\D/, '')
        attrs[:email] = "#{clean_mobile}@hush-haarentfernung.de"
      end

      attrs
    end

    def address_attributes
      attributes.with_indifferent_access.slice(*%w[street house_number city country post_code])
    end
  end
end
