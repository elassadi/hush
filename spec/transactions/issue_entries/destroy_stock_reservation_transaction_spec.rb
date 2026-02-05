RSpec.describe IssueEntries::DestroyStockReservationTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(stock_reservation_id: stock_reservation.id)
    end

    include_context "setup demo account and user"

    let(:operation) do
      instance_double(IssueEntries::DestroyStockReservationOperation)
    end

    let(:issue) { create(:issue) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
    let!(:stock_reservation) { create(:stock_reservation, article:, originator: issue_entry, qty: 1) }

    before do
      allow(IssueEntries::DestroyStockReservationOperation).to receive(:new).and_return(operation)
    end

    context "with valid data " do
      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(stock_reservation))
        expect(call).to be_success
        expect(call.success).to eq(stock_reservation)
      end
    end
  end
end
