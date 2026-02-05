module Roles
  class SyncCustomerRolesOperation < BaseOperation
    attributes :roles

    def call
      result = sync_customer_roles
      if result.success?
        # Event.broadcast(:role_activated, role_id: role.id) if role.status_active?
        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def sync_customer_roles
      Role.type_customer.each do |role|
        next unless role.type_customer?

        Account.status_active.account_type_customer.each do |account|
          yield Roles::CreateOrUpdateOperation.call(
            account:,
            role_name: role.name,
            abilities: abilities(role),
            type: :customer,
            protected: true,
            plans: [account.plan]
          )
        end
      end

      Success(true)
    end

    def abilities(role)
      role.abilities.map do |a|
        { resources: [{
          name: a.resources.first, action_tags: a.action_tags, effect: a.effect
        }.with_indifferent_access] }
      end
    end
  end
end
