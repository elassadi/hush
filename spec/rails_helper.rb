# This file is copied to spec/ when you run 'rails generate rspec:install'
# require 'simplecov'
# SimpleCov.start do
#   add_filter %r{^/spec/}
#   add_filter %r{^/lib/}
# end

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'swagger_helper'
require "test_prof/recipes/rspec/let_it_be"
require "faker"
require "paper_trail/frameworks/rspec"


# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  %w[matchers].each do |dir|
    Dir[Rails.root.join("spec", "support", dir, "**", "*.rb")].each { |f| require f }
  end
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  config.include ActiveSupport::Testing::TimeHelpers
  config.include AccountHelper
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include Requests::JsonHelpers, type: :request
  config.include StringEnumHelper, type: :model

  %i[request api_operation].each do |type|
    config.include(RequestHeaderHelper, type:)
    #config.include(CurrentUserHelper, type:)
    config.extend ServiceResponseSchemaHelper, type:
  end

  FactoryBot::SyntaxRunner.class_eval do
    include RSpec::Mocks::ExampleMethods
  end

  config.include JSON::SchemaMatchers
  ::PaperTrail.enabled = false

  config.before(:each) do
    allow(GenericJob).to receive(:perform_later).and_return(true)
  end

  config.before(:each, with_cache: true) do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
  end

  config.after(:each, type: :request) do |example|
    # rubocop:disable Rails/I18nLocaleAssignment
    I18n.locale = I18n.default_locale
    # rubocop:enable Rails/I18nLocaleAssignment
    next unless response

    example.metadata[:response][:content] = {
      'application/json' => {
        example: JSON.parse(response.body, symbolize_names: true)
      }
    }
  end

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
    end
  end

end

# ActiveRecord.verbose_query_logs = true
# ActiveRecord::Base.logger = Logger.new(STDOUT)
