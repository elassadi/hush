module Roles
  class DeleteCustomerRoleAbilitiesOperation < BaseOperation
    attributes :account

    def call
      delete_role_abilities
      Success(true)
    end

    private

    def delete_role_abilities
      account.roles.type_customer.each do |role|
        next unless role.protected?

        role.abilities.destroy_all
      end
    end
  end
end
