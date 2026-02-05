# frozen_string_literal: true

class WebhookJob < ApplicationJob
  attr_reader :webhook_request_job, :webhook_request

  MAX_RETRY = 4

  def perform(request_id)
    @webhook_request = WebhookRequest.where(status: %i[retry pending]).find(request_id)

    @webhook_request_job = WebhookRequestJob.create(webhook_request:)
    begin
      result = request_service_klass.call(request: webhook_request)
      save_result(result)
    rescue StandardError => e
      save_exception(e)
      raise e unless retry_counter_exceeded?
    end
  end

  def request_service_klass
    {
      # "StripeWebhookRequest" => Stripe::Webhooks::RequestService,
      # "StripeWebhookRequest" => Stripe::Webhooks::RequestService,
      "SmsWebhookRequest" => Sms::Webhooks::RequestService
    }[webhook_request.type]
  end

  def save_result(result)
    webhook_request.reload
    return webhook_request_job.destroy if webhook_request.status_skipped?

    webhook_request_job.update(result_attr(result))
    webhook_request.update(status: result_attr(result)[:status])
  end

  def result_attr(result)
    return { status: :failure, result: result.inspect } unless result.is_a?(Dry::Monads::Result)
    return { status: :success, result: {} } if result.success?

    { status: :failure, result: result.failure.inspect }
  end

  def save_exception(result)
    increase_retry_counter
    status = retry_counter_exceeded? ? :failure : :retry
    webhook_request.update(status:)

    webhook_request_job.update(status: :failure, result: result.inspect)
  end

  def increase_retry_counter
    webhook_request.increment!(:retry_counter, 1)
  end

  def retry_counter_exceeded?
    webhook_request.retry_counter >= MAX_RETRY
  end
end
