RSpec.describe IssueEntries::CreateStockReservationTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_entry_id: issue_entry.id)
    end

    include_context "setup demo account and user"

    let(:operation) do
      instance_double(IssueEntries::CreateStockReservationOperation)
    end

    let(:issue) { create(:issue) }
    let(:article) { create(:article) }
    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 1, price: 10) }

    before do
      allow(IssueEntries::CreateStockReservationOperation).to receive(:new).and_return(operation)
    end

    context "with valid data " do
      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(issue_entry))
        expect(call).to be_success
        expect(call.success).to eq(issue_entry)
      end
    end
  end
end
