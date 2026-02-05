RSpec.describe IssueEntries::UpdatePriceTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id,
                           issue_entry_ids: issue_entries.map(&:id), user_given_set_price: 150.0)
    end

    include_context "setup demo account and user"

    let(:issue) { create(:issue) }
    let(:repair_set) { create(:repair_set) }
    let(:issue_entries) { create_list(:issue_entry, 3, issue:, repair_set_id: repair_set.id) }

    before do
      allow(IssueEntries::UpdatePriceOperation).to receive(:call).and_return(Dry::Monads::Success(issue_entries))
    end

    context "when the update is successful" do
      it "returns a success result" do
        expect(call).to be_success
        expect(call.success).to eq(issue_entries)
      end
    end
  end
end
