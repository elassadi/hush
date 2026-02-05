# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RecloudCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    # config.api_only = true

    config.i18n.available_locales = %i[de en]
    config.i18n.default_locale = :de
    # config.middleware.use ::MiddlewareHealthcheck
    # config.middleware.insert_after Rails::Rack::Logger, ::MiddlewareHealthcheck

    # required for Sidekiq::Web
    # https://github.com/mperham/sidekiq/blob/master/Changes.md#620
    # config.session_store :cookie_store, key: "_core_api_session"

    # config.active_job.queue_adapter = :sidekiq
    # config.active_job.queue_adapter = :delayed_job

    config.active_record.default_timezone = :utc
    config.time_zone = 'Berlin'

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    #config.middleware.use ActionDispatch::Session::CookieStore, {:key=>"_recloud_core_session", domain: :all}
    config.middleware.use ActionDispatch::Session::CookieStore, {:key=>"_recloud_core_session"}




    console do
      #Current.user = User.system_user
      #::PaperTrail.request.whodunnit = User.system_user
      #::PaperTrail.request.controller_info = { whodunnit_type: "User" }
    end

    config.after_initialize do
      config.event_klasses = Event.load_klasses
    end

    Rails.application.reloader.to_prepare do
      Rails.application.config.event_klasses = Event.load_klasses
    end if Rails.env.development?

  end
end
