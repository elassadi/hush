RSpec.describe PurchaseOrders::SyncBySupplierSourceTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(supplier_source_id: supplier_source.id)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(PurchaseOrders::SyncBySupplierSourceOperation)
    end

    before do
      allow(PurchaseOrders::SyncBySupplierSourceOperation).to receive(:new)
        .with({ supplier_source: })
        .and_return(operation)
    end

    context "with valid data " do
      let(:article) { create(:article) }
      let(:supplier_source) { create(:supplier_source, article:) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(supplier_source))
        expect(call).to be_success
        expect(call.success).to eq(supplier_source)
      end
    end
  end
end
