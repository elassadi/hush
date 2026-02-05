# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.4'

# Reduces boot times through caching; required in config/boot.rb
gem 'after_party', git: 'https://github.com/mgis-it/after_party.git', branch: :master
gem "active_model_serializers"
gem 'active_storage_validations'
gem 'after_transaction_commit'
gem 'azure-storage-blob', require: false
gem 'bcrypt'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'braintree', '~> 4.6.0'
gem 'cancancan'
gem 'csv'
gem 'data_migrate'
gem 'devise'
gem 'devise-i18n'

gem 'down', '~> 5.0'
gem 'dry-auto_inject'
gem 'dry-container'
gem 'dry-monads'
gem 'dry-schema'
gem "faker"
gem 'faraday'
gem "importmap-rails"
gem 'icalendar'
gem "jbuilder"
gem 'mysql2'
gem 'paper_trail'
gem 'pry-rails'
gem 'puma', '5.6.4'
gem 'rack-protection'
gem 'rails-i18n'
gem 'redis', '~> 4.0'
gem 'rswag-api'
gem 'rswag-ui'
gem 'ruby_sms', git: 'https://github.com/elassadi/ruby_sms.git', tag: 'v1.0.4'
gem "sassc-rails"
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem "smarter_csv"
gem 'sidekiq', '~> 7.0.0'
gem 'sidekiq-scheduler'
# gem "sidekiq-statistic"
gem 'sidekiq-unique-jobs'
# gem 'skylight'
gem 'sprockets-rails'
gem "stimulus-rails"
gem "stripe"
gem 'silencer', '~> 1.0.1'
gem 'thruster'
gem 'typhoeus'
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "turbo-rails"
gem "workflow"
gem 'devise-two-factor'
gem "recaptcha"
gem 'rqrcode'
gem 'simple_form'

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'rails_performance'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'dotenv-rails'
  gem "i18n_generators"
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'active_record_query_trace'
  gem "rubycritic", require: false
  gem 'listen'
  # gem "checkpoint-rails"
end

group :test do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'json-schema'
  gem 'json-schema-rspec'
  gem 'mock_redis'
  gem 'shoulda-matchers'
  gem 'test-prof', '~> 1.0'
  gem 'webmock'
  # gem 'simplecov', '>= 0.18.0', require: false
end

# Add sub modal resource abilities
# gem 'avo', path: '/Users/Profis/myrecloud/development/avo'
gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.24'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.23'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.22'
# version 21 ist with resource edit views as default and needs to be merged wiht 22
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.20'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.19' # Buggy
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.18'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.17'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.14'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.13'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.12'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.10'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.8'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.7'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.6'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.27.1'
# gem 'avo', git: 'https://github.com/elassadi/avo.git', branch: :'core-2.30'

gem "pundit"

# Active Storage makes it simple to upload and reference files
gem "activestorage"

# High-level image processing wrapper for libvips and ImageMagick/GraphicsMagick
gem "image_processing"

# All sorts of useful information about every country packaged as convenient little country objects.
# gem "countries"

# Create beautiful JavaScript charts with one line of Ruby
gem "chartkick"
gem "turbo_ready", "= 0.1.2"
gem "tailwindcss-rails", "~> 2.0"

# fix problems with new version view component and ransac
gem "view_component", "2.82"
gem "ransack", "3.2.1"
# pin pagy version to 6.1.0 to avoid breaking changes in 7.x.x
# the buttons looks bigger and the pagination is working properly
gem "pagy", "6.1.0"
gem "kamal", "~> 2.2.1"
