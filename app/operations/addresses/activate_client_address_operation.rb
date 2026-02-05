module Addresses
  class ActivateClientAddressOperation < BaseOperation
    attributes :address

    def call
      result = activate
      return Failure(result.failure) unless result.success?

      address = result.success
      Event.broadcast(:client_address_activated, address_id: address.id) if address.status_active?

      Success(address)
    end

    private

    def activate
      yield validate_statuses
      yield activate_client_address
      yield update_live_contract

      Success(address)
    end

    def activate_client_address
      current_active_address&.status_archived!
      address.status_active!

      Success(true)
    end

    def update_live_contract
      return Success(true) unless live_contract

      create_address.call(contract: live_contract, client_address: address)
    end

    def validate_statuses
      unless address.status_draft?
        return Failure("#{self.class} invalid_status Must be draft address_id: #{address.id} ")
      end

      Success(true)
    end

    def current_active_address
      client.addresses.find_by(status: :active)
    end

    def live_contract
      @live_contract ||= client.live_contract
    end

    def client
      @client ||= address.addressable
    end

    def create_address = Contracts::CreateAddressOperation
  end
end
