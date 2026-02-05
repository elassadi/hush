RSpec.describe Converter::ApiClient, aggregate_failures: true do
  subject(:service) { described_class.new }

  let(:body) { "Hello {{name}}" }
  let(:data) { { name: "John" } }
  let(:parse_result) { double }

  describe '#parse' do
    before do
      stub_request(:post, "#{ENV.fetch('CONVERTER_URL')}/parse").to_return(status: 200, body: "binary-data", headers: {})
    end

    subject(:call) { service.parse(body:, data:, name: "not_used_for_now") }

    context 'with valid data' do
      it 'return successfull object ' do
        expect(call).to be_success
        expect(call.success.body).to include("binary-data")
      end
    end
  end
end
