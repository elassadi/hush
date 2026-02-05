module Customers
  class UpdateTransaction < BaseTransaction
    attributes :customer_id, :attributes

    def call
      customer = Customer.by_account.find(customer_id)
      ActiveRecord::Base.transaction do
        yield create_customer.call(customer:, attributes:)
      end
      Success(customer)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed to create a customer with #{e.result.failure}"
      )
      raise
    end

    private

    def create_customer = Customers::UpdateOperation
  end
end
