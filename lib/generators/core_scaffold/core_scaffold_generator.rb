class CoreScaffoldGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
  class_option :namespace, type: :string
  class_option :pluralize, type: :boolean, default: true

  def create
    template "resource/transaction.tt", "app/transactions/#{module_folder}/#{transaction_file_name}.rb"
    template "resource/operation.tt", "app/operations/#{module_folder}/#{operation_file_name}.rb"
    template "resource/action.tt", "app/avo/actions/#{module_folder}/#{action_file_name}.rb"
    template "resource/transaction_spec.tt", "spec/transactions/#{module_folder}/#{transaction_file_name}_spec.rb"
    template "resource/operation_spec.tt", "spec/operations/#{module_folder}/#{operation_file_name}_spec.rb"
  end

  def transaction_class
    "#{class_name.camelize}Transaction"
  end

  def operation_class
    "#{class_name.camelize}Operation"
  end

  def klass
    class_name.camelize
  end

  def module_folder
    mod = options['namespace'].underscore
    options['pluralize'] ? mod.pluralize : mod
  end

  def module_name
    name = options['namespace'].camelize
    options['pluralize'] ? name.pluralize : name
  end

  def transaction_file_name
    "#{singular_name}_transaction"
  end

  def operation_file_name
    "#{singular_name}_operation"
  end

  def action_file_name
    "#{singular_name}_action"
  end

  def model
    options['namespace'].underscore.downcase
  end

  def model_class
    options['namespace'].camelize
  end

  def action_name
    class_name.underscore
  end

  def current_models
    ActiveRecord::Base.connection.tables.map do |model|
      model.capitalize.singularize.camelize
    end
  end
end
