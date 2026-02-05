module Roles
  class SyncCustomerRolesTransaction < BaseTransaction
    attributes :role_ids

    def call
      roles = Role.where(id: role_ids)
      ActiveRecord::Base.transaction do
        yield sync_customer_roles.call(roles:)
      end
      Success(true)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for role #{role_ids} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def sync_customer_roles = Roles::SyncCustomerRolesOperation
  end
end
