class EventGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
  class_option :namespace, type: :string
  argument :event_actions, type: :array, default: []

  def create_event_file
    # template 'event.rb.erb', event_file_path

    event_actions.each do |action|
      @action = action
      template "event.tt", "app/events/#{module_folder}/#{event_folder_name}/#{action}.rb"
      template "event_rspec.tt", "spec/events/#{module_folder}/#{event_folder_name}/#{action}_spec.rb"
    end
  end

  private

  def module_constant_name
    module_name.camelize
  end

  def module_event_name
    "#{event_name.camelize}Event"
  end

  def event_action_name
    "#{event_name.camelize}Event"
  end

  def event_folder_name
    "#{event_name}_event"
  end

  def module_name
    options['namespace'].camelize.pluralize
  end

  def event_name
    class_name.underscore
  end

  def module_folder
    options['namespace'].underscore.pluralize
  end

  #===================================================================================================
end
