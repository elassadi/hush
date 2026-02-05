RSpec.describe IssueEntries::DestroyStockReservationOperation do
  xdescribe "#call" do
    subject(:call) do
      described_class.call(stock_reservation:)
    end

    include_context "setup demo account and user"

    let(:issue) { create(:issue) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
    let!(:stock_reservation) { create(:stock_reservation, article:, originator: issue_entry, qty: 1) }

    context 'when Reservation exist' do
      it 'destrpy the stock reservation and trigger an event' do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { StockReservation.count }.by(-1)
        expect(subject).to be_success
        expect(subject.success).not_to be_persisted
        expect(subject.success).to be_a(StockReservation)
        expect(Event).to have_received(:broadcast).with(:stock_reservation_destroyed,
                                                        stock_reservation_id: stock_reservation.id,
                                                        article_id: stock_reservation.article_id,
                                                        stock_reservation_hsh: stock_reservation)
      end
    end
  end
end
