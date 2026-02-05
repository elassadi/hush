RSpec.describe Suppliers::FetchStockDataOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(supplier:)
    end
    SOME_URL = "http://example.com".freeze

    before do
      stub_request(:get, SOME_URL).to_return(status: 200, body: "<data>", headers: {})
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    context "with supplier data" do
      let(:supplier) do
        create(:supplier, company_name: "faroline",
                          stock_api_url: SOME_URL)
      end

      it "returns success result" do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { Document.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to be_a(Document)
        expect(Event).to have_received(:broadcast).with(
          :supplier_article_import_requested, supplier_id: supplier.id,
                                              document_id: subject.success.id, current_user_id: demo_user.id
        )
      end
    end
  end
end
