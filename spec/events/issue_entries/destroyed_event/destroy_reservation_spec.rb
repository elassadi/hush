RSpec.describe IssueEntries::DestroyedEvent::DestroyReservation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:issue) { create(:issue) }
  let(:article) { create(:article) }
  let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }

  let(:stock_location) { create(:stock_location) }
  let(:stock_area) { create(:stock_area, stock_location:) }

  describe "#call" do
    subject(:call) do
      described_class.call(stock_reservation_id: stock_reservation.id)
    end

    let(:sync_transaction) do
      instance_double(IssueEntries::DestroyStockReservationTransaction)
    end

    before do
      allow(IssueEntries::DestroyStockReservationTransaction).to receive(:new).and_return(sync_transaction)
    end

    context "with a Reservation" do
      let!(:stock_reservation) do
        create(:stock_reservation, qty: 1, article: article.reload, originator: issue_entry)
      end
      it "returns success result" do
        expect(sync_transaction).to receive(:call).and_return(Dry::Monads::Success(true))
        # expect { call }.to(change { StockReservation.count }.by(-1))
        expect(call).to be_success
        expect(call.success).to be_truthy
      end
    end
  end
end
