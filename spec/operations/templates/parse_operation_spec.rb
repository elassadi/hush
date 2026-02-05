RSpec.describe Templates::ParseOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:html_content) do
    %{
      <html>
        <body>
          <h1>Invoice</h1>
          <p>Customer: John</p>
        </body>
      </html>
    }
  end

  let(:faraday_response) { instance_double(Faraday::Response, success?: true, body: html_content) }

  let(:parser_api_instance) { instance_double(::Converter::ApiClient) }
  let(:parser_result) { Dry::Monads::Success(faraday_response) }

  describe "#call" do
    before do
      allow(::Converter::ApiClient).to receive(:new).and_return(parser_api_instance)
    end

    subject(:call) do
      described_class.call(template:, data:)
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
        expect(parser_api_instance).to receive(:parse).and_return(parser_result)
        result = call
        expect(result).to be_success
        expect(result.success.body).to eq(html_content)
      end
    end
  end
end
