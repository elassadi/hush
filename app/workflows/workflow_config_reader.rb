class WorkflowConfigReader < ::RecloudCore::DryBase
  attributes :config_name

  def call
    config = read_config
    Success(config)
  end

  private

  def read_config
    # abilies_configuration["roles"].each do |role_definition|
    #   Roles::CreateOrUpdateOperation.call(account:, **role_data(role_definition))
    # end
    workflow_configuration
  end

  def workflow_configuration
    @workflow_configuration ||= YAML.load(
      Rails.root.join("config/workflows/#{config_name}.yaml").read
    )
  end
end
