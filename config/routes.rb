# frozen_string_literal: true
require 'sidekiq/web'
require 'sidekiq-scheduler/web'

CUSTOMER_SUBDOMAINS ||= %w[app]
Rails.application.routes.draw do



  # system calls
  get '/webhooks/dyndns', to: 'webhook#dyndns'

  resources :leads, only: [:create]
  get '/agb', to: 'static_pages#agb', as: :agb
  get '/legal', to: 'static_pages#legal', as: :legal
  get  '/contact', to: 'static_pages#contact', as: :contact
  get  '/message_sent', to: 'static_pages#thanks', as: :leads_thanks

  constraints :subdomain => CUSTOMER_SUBDOMAINS  do
    get '/agb', to: 'static_pages#agb', as: :app_agb
    get '/legal', to: 'static_pages#legal', as: :app_legal
  end



  constraints :subdomain => CUSTOMER_SUBDOMAINS do
    get 'booking', to: 'booking#show'
    get 'booking/thanks', to: 'booking#thanks'
  end

  resources :booking, only: [:show] do
    get 'thanks', to: 'booking#thanks', on: :member
  end



  post '/webhooks/sms', to: 'webhook#sms'



  namespace :api, defaults: { format: 'json' } do
    namespace :partner do
      resources :device_manufacturers, only: [:index]
      resources :device_models, only: [:index]
      resources :repair_sets, only: [:index]
      resources :issue_calendar_entries, only: [:create]
      resources :calendar_entries, only: [] do
        collection do
          get 'available_slots'
        end
      end
      resources :merchants, only: [] do
        collection do
          get 'branches'
        end
      end

      #resources :clients, only: [:index, :show, :create, :update, :destroy]
      # get "/quotes/:uuid", to: "quotes#show"
      # resources :contracts, only: [:show, :create]
      # resources :agents, only: [:show, :create]
      # resources :agency_contracts, only: [:create]
    end
  end


  # public routes
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }, skip: [:registrations]


  devise_scope :user do
    get "users/login_as", to: "users/sessions#login_as", as: :login_as
    get "users/activation_pending", to: "users/sessions#activation_pending", as: :activation_pending
  end

  authenticate :user do
    constraints :subdomain => CUSTOMER_SUBDOMAINS do
      mount Avo::Engine, at: Avo.configuration.root_path
    end
  end
  #mount Avo::Engine, at: Avo.configuration.root_path



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
        get "users/keep_alive", to: "users#keep_alive"
        get "abilities/actions", to: "abilities#actions"
        get "notifications/preview", to: "notifications#preview"
        get "stocks/areas", to: "stocks#areas"
        get "stocks/default_stock", to: "stocks#default_stock"
        get "devices/colors", to: "devices#colors"
        get "devices/list_colors", to: "devices#list_colors"
        get "devices/list_devices_for_customer", to: "devices#list_devices_for_customer"
        get "devices/fetch_by_imei", to: "devices#fetch_by_imei"
        get "devices/:id/list_repair_sets", to: "devices#list_repair_sets", as: :list_repair_sets
        get "global_settings", to: "global_settings#show", as: :global_settings
        get "application_settings", to: "application_settings#show"
        get "booking_settings", to: "booking_settings#show"
        get "purchase_orders/:id/split_helper", to: "purchase_orders#split_helper", as: :purchase_order_split_helper
        get "issues/:id/preview_document", to: "issues#preview_document", as: :issue_preview_document
        get "issues/table_possible_repair_sets", to: "issues#table_possible_repair_sets", as: :table_possible_repair_sets
      end

      get "calendar_tool", to: "tools#calendar_tool"
      get "error_page", to: "tools#error_page"

      constraints :subdomain => CUSTOMER_SUBDOMAINS do
        get "issue_wizard", to: "issue_wizard#show"
        get "entries_summary", to: "entries_summary#show"
        get "commentable", to: "commentable#show"
      end
    end

  end
  # if Rails.env.development?
  #   get '/static/', to: 'static_pages#index'
  # else
  # end




  # Root route - shows wellness page with default language (no redirect)
  root to: 'hush#wellness', as: :home

  # HUSH Wellness Pages with locale support
  scope '(:locale)', locale: /de|en/ do
    get '/wellness', to: 'hush#wellness', as: :wellness
    get '/waxing_termin', to: 'hush#waxing_appointment', as: :waxing_appointment
    get '/waxing_appointment', to: 'hush#waxing_appointment'
    get '/waxing_appointment/thanks', to: 'hush#waxing_appointment_thanks', as: :waxing_appointment_thanks
    get '/about', to: 'hush#about', as: :about
    get '/impressum', to: 'hush#impressum', as: :impressum
    get '/datenschutz', to: 'hush#datenschutz', as: :datenschutz
  end

  # Default wellness route (without locale - uses default language)
  get '/wellness', to: 'hush#wellness'
  get '/waxing_termin', to: 'hush#waxing_appointment'
  get '/termin-buchen', to: 'hush#waxing_appointment'
  get '/appointment', to: 'hush#waxing_appointment'
  get '/waxing_appointment', to: 'hush#waxing_appointment'
  get '/waxing_appointment/thanks', to: 'hush#waxing_appointment_thanks'
  get '/about', to: 'hush#about'
  get '/impressum', to: 'hush#impressum'
  get '/datenschutz', to: 'hush#datenschutz'

end

