class Event < ApplicationRecord
  string_enum :status, %w[pending retry success failure], _default: :pending
  attribute :sender
  has_many :event_jobs, dependent: :destroy

  EventNotRegisteredError = Class.new(StandardError)

  def registered?
    klasses.present?
  end

  def klass
    klass_name.constantize
  end

  def _klass
    @klass ||= ::RecloudCore::Application.config.event_klasses.detect do |klass|
      klass.event_name.to_s == name.to_s
    end
  end

  def klasses
    @klasses ||= ::RecloudCore::Application.config.event_klasses.select { |klass| klass.event_name.to_s == name.to_s }
  end

  def klasses_by_prio
    klasses.select(&:prio).sort_by { |klass| [klass.prio, klass.to_s] }.reverse
    # klasses.group_by(&:event_name).transform_values { |values| values.sort_by(&:prio).reverse }
  end

  def current_user
    return nil unless data["current_user_id"]

    User.find(data["current_user_id"])
  end

  class << self
    def broadcast(event_name, async: true, wait: nil, **args)
      event = Event.new(name: event_name, data: args&.to_h)
      return unless event.registered?

      queue_or_run_event_job(event:, async:, wait:, **args)
    end

    def queue_or_run_event_job(event:, async:, wait:, **args)
      return true if should_skip_event_job?(async)

      args[:current_user_id] = fetch_current_user_id(args)
      runner = determine_runner(wait, async)

      ActiveRecord::Base.connection.after_transaction_commit do
        # TODO: mock event broadcasting
        run_event_jobs(event, runner, async, args)
      end
    end

    def should_skip_event_job?(async)
      Rails.env.test? && async
    end

    def fetch_current_user_id(args)
      args[:current_user_id] || args["current_user_id"] || Current.user.id
    end

    def determine_runner(wait, async)
      wait && async ? EventJobRunner.set(wait:) : EventJobRunner
    end

    def create_and_perform_event(event:, klass:, runner:, async:, **args)
      target_class = args[:target_class]
      if target_class && target_class != klass.to_s
        # we skip the event if the target class is not the same as the klass
        return true
      end

      child_event = Event.create!(name: event.name, prio: klass.prio, klass_name: klass.to_s, data: args&.to_h)
      return runner.perform_later(child_event.id) if async

      runner.perform_now(child_event.id)
    end

    def load_klasses
      Dir.glob("**/*.rb", base: Rails.root.join("app/events")).filter_map do |path|
        path.sub!(/.rb\z/, "")
        next if path == "base_event"

        path.camelize.constantize
      end
    end

    def run_event_jobs(event, runner, async, args)
      run_non_priority_jobs(event, runner, async, args)
      run_priority_jobs(event, runner, async, args)
    end

    def run_non_priority_jobs(event, runner, async, args)
      event.klasses.each do |klass|
        create_and_perform_event(event:, klass:, runner:, async:, **args) if klass.prio.blank?
      end
    end

    def run_priority_jobs(event, runner, async, args)
      first_priority_klass = event.klasses_by_prio.first
      create_and_perform_event(event:, klass: first_priority_klass, runner:, async:, **args) if first_priority_klass
    end
  end
end
