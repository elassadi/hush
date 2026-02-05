module Roles
  class CreateOrUpdateOperation < BaseOperation
    attributes :account, :role_name, :abilities, :type, :protected, :plans

    CreateAdminRoleError = Class.new(StandardError)
    def call
      result = create_role
      role = result.success
      return Success(role) if result.success?

      Failure(result.failure)
    end

    private

    def create_role
      # raise CreateAdminRoleError, "Create System roles is forbidden" if type != :customer
      return Success(true) if skip_by_account_role_creation?
      return Success(true) if skip_by_plan_role_creation?

      role = Role.find_or_create_by(name: role_name, account:)
      role.update!(type:, protected:)
      role.abilities.destroy_all
      create_new_abilities(role)
      Success(role)
    end

    def create_new_abilities(role)
      abilities.each do |ability|
        ability[:resources].each do |resource_ability|
          role.abilities.create!(
            account:,
            effect: resource_ability["effect"] || :allow,
            resources: Array(resource_ability["name"]),
            action_tags: resource_ability["action_tags"]
          )
        end
      end
    end

    def skip_by_account_role_creation?
      (type == :system && !account.recloud?) || (type == :customer && account.recloud?)
    end

    def skip_by_plan_role_creation?
      return false if plans.blank? || account.recloud?

      plans.exclude?(account.plan)
    end
  end
end
