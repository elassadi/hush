RSpec.describe PurchaseOrders::ShouldDestroyTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(stock_reservation_hsh:)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(PurchaseOrders::ShouldDestroyOperation)
    end

    before do
      allow(PurchaseOrders::ShouldDestroyOperation).to receive(:new).and_return(operation)
    end

    context "with valid data " do
      let(:article) { create(:article) }
      let(:stock_reservation_hsh) do
        {
          article_id: 10,
          qty: 1
        }
      end

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(true))
        expect(call).to be_success
        expect(call.success).to eq(true)
      end
    end
  end
end
