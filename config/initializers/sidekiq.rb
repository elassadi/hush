# frozen_string_literal: true

# Sidekiq.logger = Rails.logger

::Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_SIDEKIQ_URL'] }
  # Similar to sidekiq logs, so may be just disabled
end

::Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_SIDEKIQ_URL'] }
end
