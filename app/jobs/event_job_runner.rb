# frozen_string_literal: true

class EventJobRunner < ApplicationJob
  attr_reader :event, :event_job

  MAX_RETRY = 4

  def perform(event_id)
    @event = Event.find(event_id)
    @event_job = create_event_job(@event, event.klass_name, event.data)
    Current.user = @event.current_user
    begin
      result = @event_job.klass.call(event.data)
      save_result(result)
      schedule_next_job_by_prio
    rescue StandardError => e
      save_error(e)
      raise e unless retry_counter_exceeded?
    end
  end

  private

  def with_next_event_by_prio
    return unless next_event_klass_by_prio

    yield
  end

  def with_next_event_klass_by_prio
    start_prio = event.klass_name.constantize.prio || 0

    klasses = event.klasses_by_prio.drop_while { |k| k.to_s != event.klass_name }.drop(1)

    next_event_klass = klasses.find do |klass|
      (klass.prio || 0) <= start_prio
    end

    yield(next_event_klass) if next_event_klass
  end

  def schedule_next_job_by_prio
    return if event.klass.prio.blank?

    job =  with_next_event_klass_by_prio do |klass|
      Event.create!(name: event.name, prio: klass.prio, klass_name: klass.to_s, data: event.data)
    end

    return unless job

    EventJobRunner.perform_later(job.id)
  end

  def create_event_job(event, klass_name, args)
    EventJob.create(
      event:,
      klass_name:,
      data: args
    )
  end

  def save_result(result)
    event_job.update(result_attr(result))
    event.update(status: result_attr(result)[:status])
  end

  def result_attr(result)
    return { status: :failure, result: result.inspect } unless result.is_a?(Dry::Monads::Result)

    return { status: :success, result: result.success.inspect } if result.success?

    { status: :failure, result: result.failure.inspect }
  end

  def save_error(result)
    increase_retry_counter
    status = retry_counter_exceeded? ? :failure : :retry
    event.update(status:)

    event_job.update(status: :failure, result: result.inspect)
  end

  def increase_retry_counter
    event.increment!(:retry_counter, 1)
  end

  def retry_counter_exceeded?
    event.retry_counter >= MAX_RETRY
  end
end
