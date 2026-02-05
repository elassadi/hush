RSpec.describe PurchaseOrders::StockOrderTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order_id: purchase_order.id)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(PurchaseOrders::StockOrderOperation)
    end

    before do
      allow(PurchaseOrders::StockOrderOperation).to receive(:new).and_return(operation)
    end

    context "with valid data " do
      let(:purchase_order) { create(:purchase_order) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
        expect(call.success).to eq(true)
      end
    end
  end
end
