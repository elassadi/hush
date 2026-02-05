RSpec.describe Sms::RecloudSmsApiClient, aggregate_failures: true do
  subject(:service) { described_class.new }

  let(:text) { "Hello you" }
  let(:to) { ["+4917611716177"] }

  describe '#send_message' do
    before do
      # allow(::Converter::ApiClient).to receive(:new).and_return(converter_api_instance)
      stub_request(:post, "#{ENV.fetch('RECLOUD_SMS_API_URL')}/message").to_return(status: 200, body: "binary-data", headers: {})
    end

    subject(:call) { service.send_message(text:, to:) }

    context 'with valid data' do
      it 'return successfull object ' do
        expect(call).to be_success
        expect(call.success.body).to include("binary-data")
      end
    end
  end
end
