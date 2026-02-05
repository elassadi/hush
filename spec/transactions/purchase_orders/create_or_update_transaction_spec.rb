RSpec.describe PurchaseOrders::CreateOrUpdateTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(stock_reservation_id: stock_reservation.id)
    end

    include_context "setup system user"
    include_context "setup demo account and user"

    let(:operation) do
      instance_double(PurchaseOrders::CreateOrUpdateOperation)
    end

    before do
      allow(PurchaseOrders::CreateOrUpdateOperation).to receive(:new).and_return(operation)
    end

    context "with valid data " do
      let(:article) { create(:article) }
      let(:stock_reservation) { create(:stock_reservation, article:, qty: 1) }

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(stock_reservation))
        expect(call).to be_success
        expect(call.success).to eq(stock_reservation)
      end
    end
  end
end
