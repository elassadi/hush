RSpec.describe PurchaseOrders::TransitionToTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(purchase_order_id: purchase_order.id,
                           event: "someevent", comment: "somecomment",
                           owner: system_user)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(PurchaseOrders::TransitionToOperation)
    end

    before do
      allow(PurchaseOrders::TransitionToOperation).to receive(:new).and_return(operation)
    end

    context "with valid status" do
      let(:purchase_order) { create(:purchase_order) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(purchase_order))
        expect(call).to be_success
        expect(call.success).to eq(purchase_order)
      end
    end
  end
end
