RSpec.describe Templates::ConvertOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:pdf_file) { Rails.root.join("spec/fixtures/test.pdf") }
  let(:pdf_content) { File.read(pdf_file) }
  let(:faraday_response) { instance_double(Faraday::Response, success?: true, body: pdf_content) }
  let(:converter_api_instance) { instance_double(::Converter::ApiClient) }
  let(:converter_result) { Dry::Monads::Success(faraday_response) }
  let!(:global_settings) { create(:global_setting) }
  let!(:application_settings) { create(:application_setting) }
  let(:documentable) do
    create(:issue)
  end

  describe "#call" do
    before do
      allow(::Converter::ApiClient).to receive(:new).and_return(converter_api_instance)
    end

    subject(:call) do
      described_class.call(template:, data:,
                           account_id: Account.recloud.id,
                           documentable:,
                           document_class: Document)
    end

    context "With valid data" do
      let(:template) do
        create(:template, template_type: :print, name: :invoice, body:
          %{
            <html>
              <body>
                <h1>Invoice</h1>
                <p>Customer: {{customer.name}}</p>
              </body>
            </html>
          })
      end
      let(:data) do
        { customer: { name: "John" }, items: [{ name: "item1", price: 10 }, { name: "item2", price: 20 }] }
      end

      it "it parse template and broadcast event " do
        expect(converter_api_instance).to receive(:convert).and_return(converter_result)
        expect do
          result = call
          expect(result).to be_success
          expect(result.success).to be_an_instance_of(Document)
          expect(result.success.file.blob.byte_size).to eq(File.size(pdf_file))
        end.to change(Document, :count).by(1)
      end
    end
  end
end
