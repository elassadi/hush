module Addresses
  class ActivateOperation < BaseOperation
    attributes :address

    def call
      result = activate
      return Failure(result.failure) unless result.success?

      address = result.success
      Event.broadcast(:address_activated, address_id: address.id) if address.status_active?

      Success(address)
    end

    private

    def activate
      yield validate_statuses
      yield activate_address

      Success(address)
    end

    def activate_address
      current_active_address&.status_archived!
      address.status_active!

      Success(true)
    end

    def current_active_address
      address.addressable.addresses.find_by(status: :active)
    end

    def validate_statuses
      unless address.status_draft?
        return Failure("#{self.class} invalid_status Must be draft address_id: #{address.id} ")
      end

      Success(true)
    end
  end
end
