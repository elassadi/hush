RSpec.configure do |config|
  config.before do
    allow(ModelInstancePersistenceJob).to receive(:perform_later)
  end
end
