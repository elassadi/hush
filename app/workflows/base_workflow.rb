class BaseWorkflow < RecloudCore::DryBase
  include Workflow
  attr_accessor :resource

  def initialize(resource, workflow_name: :default)
    @resource = resource
    @workflow_name = workflow_name
    load_workflow
  end

  def state
    current_state.to_s
  end

  def possible_events
    current_state.events.pluck(0)
  end

  def events_visible_for_actions
    current_state.events.select do |_, events|
      events.none? { |event| event.meta["hide"] == true } &&
        events.any? { |event| can_run_event?(event.name) }
    end.pluck(0)
  end

  def can_run_event?(event)
    return false unless respond_to?("can_#{event}?")
    return false unless Current.user.can?(event.to_sym, resource)
    return false if resource.respond_to?(:locked?) && resource.locked?

    send("can_#{event}?")
  end

  def run_event!(event, event_args: {})
    result = send("#{event}!", event_args:)
    return result if result.is_a?(Dry::Monads::Result)

    result ? Success(result) : Failure("Event #{event} failed")
  end

  def state_metadata_by_event(state:, event:); end

  def add_event(context, event, methods); end

  private

  def config
    @config ||= WorkflowConfigReader.call(config_name: @workflow_name).success
  end

  # rubocop:todo Metrics/CyclomaticComplexity
  # rubocop:todo Metrics/PerceivedComplexity
  def load_workflow # rubocop:todo Metrics/AbcSize, Metrics/CyclomaticComplexity
    methods = { if: [], event: [], unless: [] }
    states = config["states"]
    self.class.workflow do |_args| # rubocop:todo Metrics/BlockLength
      states.each_key do |state|
        events = states[state]["events"]
        meta = states[state]["meta"]
        state state, meta: do
          Array(events).each do |event|
            condition_method_name = nil
            condition_method_name = "unless_#{event['unless']}" if event["unless"]
            condition_method_name = "if_#{event['if']}" if event["if"]
            condition_method_name = condition_method_name&.to_sym

            args = { transitions_to: event["transitions_to"],
                     if: condition_method_name,
                     meta: event["meta"] }.compact
            methods[:if] << condition_method_name if event["if"]
            methods[:unless] << condition_method_name if event["unless"]
            methods[:event] << event["name"].to_sym
            event event["name"], **args
          end
        end
      end
      after_transition do |from, to, triggering_event, *args|
        update_status_category(to:, triggering_event:)
        event_args = args.first
        if from != to
          ::Event.broadcast("after_transition_from_#{from}_to_#{to}",
                            from:, to:, resource_id: resource.id, triggering_event:, **event_args)
          ::Event.broadcast("after_transition_to_#{to}", from:, to:, resource_id: resource.id,
                                                         resource_class: resource.class.to_s, triggering_event:
          , **event_args)
          ::Event.broadcast("after_transition",
                            from:, to:, resource_id: resource.id,
                            resource_class: resource.class.to_s, triggering_event:, **event_args)
        end
      end
    end
    create_methods(methods)
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  def create_methods(methods)
    methods.each do |type, method_list|
      method_list.uniq.each do |method_name|
        send("create_#{type}_method", method_name)
      end
    end
  end

  def create_unless_method(unless_method)
    return if respond_to?(unless_method)

    mod = self.class.module_parent
    define_singleton_method(unless_method) do
      klass = unless_method.to_s.delete_prefix("unless_").camelize
      "#{mod}::WorkflowConditions::#{klass}".constantize.call(resource:).failure?
    end
  end

  def create_if_method(if_method)
    return if respond_to?(if_method)

    mod = self.class.module_parent
    define_singleton_method(if_method) do
      klass = if_method.to_s.delete_prefix("if_").camelize
      "#{mod}::WorkflowConditions::#{klass}".constantize.call(resource:).success?
    end
  end

  def create_event_method(event_method)
    return if respond_to?(event_method)

    mod = self.class.module_parent

    define_singleton_method(event_method) do |args|
      "#{mod}::WorkflowEvents::#{event_method.to_s.camelize}".constantize.call(resource:, **args).success?
    end
  end

  def update_status_category(to:, triggering_event:) # rubocop:todo Lint/UnusedMethodArgument
    state_data = self.class.workflow_spec.states.select { |key, _value| key.to_s == to }
    category = state_data[to.to_sym].meta["category"]
    resource.update!(status_category: category)
  end

  def load_workflow_state
    resource.status
  end

  def persist_workflow_state(state)
    resource.update(status: state)
  end

  class << self
    def options
      state_options = {}
      workflow_spec.states.each do |key, value|
        next if key == :canceld

        category = value.meta["category"]
        state_options[category.to_sym] ||= []
        state_options[category.to_sym] << key.to_s
      end
      {
        gray: state_options[:open],
        info: state_options[:in_progress],
        success: Array(state_options[:done]) + ["repairing_successfull"],
        warning: %w[],
        danger: %w[canceld repairing_unsuccessfull]
      }
    end

    def human_workflow_event_names(resource)
      events = resource.workflow.events_visible_for_actions

      events.index_with do |event|
        human_workflow_event_name(resource, event)
      end.invert
    end

    def human_workflow_event_name(resource, event)
      translation_key = "activerecord.attributes.#{resource.class.to_s.underscore}.workflow_events.#{event}"
      return I18n.t(translation_key) if I18n.exists?(translation_key)

      I18n.t(event, scope: [:shared, event])
    end

    def human_workflow_statuses(record)
      record.workflow.class.workflow_spec.states.keys.index_with do |state|
        human_workflow_status(state)
      end
    end

    def human_workflow_status(state, short: false)
      translation_key = "activerecord.attributes.issue.statuses"
      translation_key = "#{translation_key}.short" if short
      translation_key = "#{translation_key}.#{state}"
      return I18n.t(translation_key) if I18n.exists?(translation_key)

      I18n.t(state, scope: [:shared, state])
    end
  end
end
