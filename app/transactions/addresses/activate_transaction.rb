module Addresses
  class ActivateTransaction < BaseTransaction
    attributes :address_id
    attr_reader :address

    def call
      @address = Address.find(address_id)
      ActiveRecord::Base.transaction do
        yield activate_address.call(address:)
      end
      Success(address)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for address #{address_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def activate_address
      {
        "Client" => Addresses::ActivateClientAddressOperation
        # "Account" => Addresses::ActivateAccountAddressOperation,
      }[address.addressable.class.to_s] || Addresses::ActivateOperation
    end
  end
end
