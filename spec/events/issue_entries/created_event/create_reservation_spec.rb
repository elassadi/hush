RSpec.describe IssueEntries::CreatedEvent::CreateReservation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_entry_id: issue_entry.id)
    end

    include_context "setup demo account and user"

    let(:transaction) do
      instance_double(IssueEntries::CreateStockReservationTransaction)
    end

    let(:issue) { create(:issue, assignee: Current.user) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }
    let(:stock_reservation) { create(:stock_reservation, article:, qty: 1, originator: issue_entry) }

    before do
      allow(IssueEntries::CreateStockReservationTransaction).to receive(:new).and_return(transaction)
    end

    context "When event issue_entry_created is triggered" do
      it "calls the CreateStockReservationTransaction " do
        expect(transaction).to receive(:call).and_return(Dry::Monads::Success(stock_reservation))
        expect(call).to be_success
        expect(call.success).to eq(stock_reservation)
      end
    end
  end
end
