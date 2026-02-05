unless defined?(Rake.application)
  # if %w[avo:build-assets assets:precompile].any? { |task| Rake.application.top_level_tasks.include?(task) }
  #   PLAN_RESTRICTIONS_CONFIG = {}
  # else
  PLAN_RESTRICTIONS_CONFIG = YAML.load_file(Rails.root.join('config/plan_restrictions.yaml')).with_indifferent_access
  #end
else
  PLAN_RESTRICTIONS_CONFIG = {}
end