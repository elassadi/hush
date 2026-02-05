RSpec.describe PurchaseOrders::SplitTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order_id: purchase_order.id, entry_quantities: [], stock_immediately: false)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(PurchaseOrders::SplitOperation)
    end

    before do
      allow(PurchaseOrders::SplitOperation).to receive(:new)
        .with({ purchase_order:, entry_quantities: [], stock_immediately: false })
        .and_return(operation)
    end

    context "with valid data " do
      let(:purchase_order) { create(:purchase_order) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(purchase_order))
        expect(call).to be_success
        expect(call.success).to eq(purchase_order)
      end
    end
  end
end
