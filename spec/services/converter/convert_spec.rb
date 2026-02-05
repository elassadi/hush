RSpec.describe Converter::ApiClient, aggregate_failures: true do
  subject(:service) { described_class.new }

  let(:body) { "Hello {{name}}" }
  let(:data) { { name: "John" } }

  describe '#convert' do
    before do
      # allow(::Converter::ApiClient).to receive(:new).and_return(converter_api_instance)
      stub_request(:post, "#{ENV.fetch('CONVERTER_URL')}/convert").to_return(status: 200, body: "binary-data", headers: {})
    end

    subject(:call) { service.convert(body:, footer: "", data:, name: "not_used_for_now") }

    let!(:global_settings) { create(:global_setting) }
    context 'with valid data' do
      it 'return successfull object ' do
        expect(call).to be_success
        expect(call.success.body).to include("binary-data")
      end
    end
  end
end
