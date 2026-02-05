# frozen_string_literal: true

Sentry.init do |config|
  # silence the sentry debug logger
  config.logger = Logger.new('/dev/null') if Rails.env.qa?

  config.background_worker_threads = 0
  config.send_default_pii = true
  config.dsn = ENV['SENTRY_DSN']

  config.release = ENV.fetch('RELEASE_NAME', 'release_not_specified')

  config.enabled_environments = %w[production qa]
  config.environment = Rails.env

  # you can use the pre-defined job for the async callback
  # comment out section if want to sent events sync way (not recommended)
  # config.async = lambda do |event, hint|
  #   Sentry::SendEventJob.perform_later(event, hint)
  # end

  # Disable Performance monitoring on QA

  config.traces_sample_rate = 0

  # config.excluded_exceptions.delete(ActiveRecord::RecordNotFound.name)

  # DEFAULT_TRACES_SAMPLE_RATE = Rails.env.qa? ? 0.0 : 1.0
  # config.traces_sampler = lambda do |sampling_context|
  #   # transaction_context is the transaction object in hash form
  #   # keep in mind that sampling happens right after the transaction is initialized
  #   # e.g. at the beginning of the request
  #   transaction = sampling_context[:transaction_context]

  #   # if the transaction is important, set a higher rate
  #   exclude_from_apm = ["/healthcheck", "/monitoring/sidekiq"]
  #   if transaction[:name].match?(exclude_from_apm.map{|e| "^#{e}.*"}.join("|"))
  #     0
  #   else
  #     DEFAULT_TRACES_SAMPLE_RATE
  #   end
  # end
end
