# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do



  # public routes
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: "users/registrations"
  }


  devise_scope :user do
    get "users/login_as", to: "users/sessions#login_as", as: :login_as
  end

  authenticate :user do
    constraints :subdomain => 'app' do
      mount Avo::Engine, at: Avo.configuration.root_path

    end
  end



  mount Sidekiq::Web => '/monitoring/sidekiq'
  Sidekiq::Web.use ActionDispatch::Cookies
  cfg = Rails.application.config
  Sidekiq::Web.use cfg.session_store, cfg.session_options
  if Rails.env.production?
    # Sidekiq Basic Auth from routes on production environment
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking
      #     (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_AUTH_USERNAME"])
        ) &
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(password),
          ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_AUTH_PASSWORD"])
        )
    end
  end



  # Internal routes

  #mount Rswag::Ui::Engine => '/api-docs'
  #mount Rswag::Api::Engine => '/api-docs'

  get '/healthcheck', to: 'healthcheck#index'
  namespace :api, defaults: { format: 'json' } do
    get '/', to: 'api#index'
  end


  if defined? ::Avo
    Avo::Engine.routes.draw do
      scope :resources do
        get "abilities/actions", to: "abilities#actions"
        get "notifications/preview", to: "notifications#preview"
        get "stocks/areas", to: "stocks#areas"
        get "stocks/default_stock", to: "stocks#default_stock"
        get "devices/colors", to: "devices#colors"
        get "devices/fetch_by_imei", to: "devices#fetch_by_imei"
      end

      constraints :subdomain => 'app' do
        get "issue_wizard", to: "issue_wizard#show"
        get "issue_entries_summary", to: "issue_entries_summary#show"
        get "repair_set_entries_summary", to: "repair_set_entries_summary#show"
        get "commentable", to: "commentable#show"
      end
    end

  end
  # if Rails.env.development?
  #   get '/static/', to: 'static_pages#index'
  # else
  # end
  get '/', to: 'static_pages#index', as: :home

end

