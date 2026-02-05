RSpec.describe IssueEntries::CreateStockReservationOperation do
  xdescribe "#call" do
    subject(:call) do
      described_class.call(issue_entry:)
    end

    include_context "setup demo account and user"

    let(:issue) { create(:issue) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }

    context 'when no Reservation exist' do
      it 'creates a stock reservation with low priority' do
        expect { subject }.to change { StockReservation.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to be_a(StockReservation)
        expect(subject.success).to have_attributes({ prio: StockReservation::PRIO_LOW })
      end
    end

    context 'when no Reservation exist and inprogress issue' do
      let(:issue) { create(:issue, status_category: :in_progress) }
      it 'creates a stock reservation with normal priority' do
        expect { subject }.to change { StockReservation.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to be_a(StockReservation)
        expect(subject.success).to have_attributes({ prio: StockReservation::PRIO_NORMAL })
      end
    end

    context 'when a reservation exist' do
      let!(:stock_reservation) { create(:stock_reservation, article:, originator: issue_entry, qty: 1) }

      it ' will not create a stock reservation' do
        expect { subject }.to change { StockReservation.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_persisted
        expect(subject.success).to be_a(StockReservation)
      end
    end

    context 'when a reservation exist but the issue entry has no article associated' do
      let(:issue_entry) { create(:issue_entry, category: :text, issue:, article: nil, qty: 1, price: 10) }

      it ' will not create a stock reservation' do
        expect { subject }.to change { StockReservation.count }.by(0)
        expect(subject).to be_success
      end
    end
  end
end
