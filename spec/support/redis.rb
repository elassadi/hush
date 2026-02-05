require 'mock_redis'
RSpec.configure do |config|
  mocked_redis_conn = MockRedis.new
  config.before do
    mocked_redis_conn.flushdb
    allow(Redis).to receive(:new).and_return(mocked_redis_conn)
  end
end
