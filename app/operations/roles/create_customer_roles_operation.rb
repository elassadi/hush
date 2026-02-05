module Roles
  class CreateCustomerRolesOperation < BaseOperation
    attributes :account

    USE_FLAT_ABILITIES = true

    def call
      create_roles
      Success(true)
    end

    private

    def create_roles
      if USE_FLAT_ABILITIES
        flat_abilities_configuration["roles"].each do |role_definition|
          Rails.logger.debug { ">>Working on role #{role_definition['name']}" }
          Roles::CreateOrUpdateOperation.call(
            account:, role_name: role_definition["name"],
            abilities: [{ resources: role_definition["resources"] }],
            type: role_definition["type"].to_sym,
            plans: Array(role_definition["plans"]),
            protected: true
          )
        end
      else
        abilies_configuration["roles"].each do |role_definition|
          Roles::CreateOrUpdateOperation.call(account:, **role_data(role_definition))
        end
      end
    end

    def role_data(role_definition)
      role_attributes = base_role_attributes(role_definition)

      unique_resources = role_attributes[:abilities].flat_map { |ability| ability[:resources] }
                                                    .group_by { |resource| resource["name"] }
                                                    .map do |name, resources|
        { "name" => name, "action_tags" => resources.flat_map { |resource| resource["action_tags"] }.uniq }
      end

      role_attributes[:abilities] = [{ resources: unique_resources }]
      role_attributes
    end

    def base_role_attributes(role_definition)
      {
        role_name: role_definition["name"],
        type: role_definition["type"].to_sym,
        protected: true,
        abilities: role_definition["abilities"].map do |abilities_name|
          ab = abilies_configuration["abilities"].find { |a| a["name"] == abilities_name }
          raise "Ability #{abilities_name} not found" if ab.nil?

          ab.except("name").symbolize_keys
        end
      }
    end

    def abilies_configuration
      @abilies_configuration ||= YAML.load(
        Rails.root.join("config/abilities.yaml").read
      )
    end

    #==========

    def flat_abilities_configuration
      @flat_abilities_configuration ||= YAML.load(
        Rails.root.join("config/flat-abilities.yaml").read
      )
    end
  end
end
