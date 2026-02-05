class AvoResourceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create
    template "resource/resource.tt", "app/avo/resources/#{resource_name}.rb"
    template "resource/controller.tt", "app/controllers/avo/#{controller_name}.rb"
    # template "resource/policy.tt", "app/policies/#{policy_name}.rb"
  end

  def resource_class
    "#{class_name}Resource"
  end

  def controller_class
    "#{class_name.camelize.pluralize}Controller"
  end

  def policy_class
    "#{class_name.camelize}Policy"
  end

  def resource_name
    "#{singular_name}_resource"
  end

  def policy_name
    "#{singular_name}_policy"
  end

  def controller_name
    "#{plural_name}_controller"
  end

  def translation_key
    "activerecord.attributes.#{singular_name}"
  end

  def current_models
    ActiveRecord::Base.connection.tables.map do |model|
      model.capitalize.singularize.camelize
    end
  end
end
