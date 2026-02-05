RSpec.describe IssueEntries::UpdateStockReservationOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_entry:)
    end

    include_context "setup demo account and user"

    let(:issue) { create(:issue) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 4, price: 10) }

    context 'when a reservation exist' do
      let!(:stock_reservation) { create(:stock_reservation, article:, originator: issue_entry, qty: 1) }

      it ' will not create a stock reservation' do
        expect { subject }.to change { StockReservation.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to be_a(StockReservation)
        expect(subject.success).to have_attributes({ qty: 4 })
      end
    end
  end
end
