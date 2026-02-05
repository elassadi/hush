module Addresses
  module ActivatedEvent
    class CreateInsurancePolicy < BaseEvent
      subscribe_to :contract_address_created, prio: 10
      attributes :address_id

      def call
        process_address_activated if contract.status_active?

        Success(true)
      end

      private

      def process_address_activated
        yield create_insurance_policy.call(contract_id: contract.id)

        Success(true)
      end

      def contract
        @contract ||= Address.find(address_id).addressable
      end

      def create_insurance_policy = Contracts::CreateInsurancePolicyTransaction
    end
  end
end
