module Customers
  class CreateTransaction < BaseTransaction
    attributes :attributes

    def call
      customer = ActiveRecord::Base.transaction do
        yield create_customer.call(attributes:)
      end
      Success(customer)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} failed to create a customer with #{e.result.failure}"
      )
      raise
    end

    private

    def create_customer = Customers::CreateOperation
  end
end
