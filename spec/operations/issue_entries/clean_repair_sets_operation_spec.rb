RSpec.describe IssueEntries::CleanRepairSetsOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue:)
    end

    include_context "setup demo account and user"

    let(:article) { create(:article) }

    let(:issue_entry) { create(:issue_entry, issue:, article:, qty: 4, price: 10) }

    context 'when a repair is in repairing status or done' do
      let(:issue) { create(:issue, status_category: :done) }

      it 'will return a failure' do
        expect(subject).to be_failure
      end
    end
    context 'when a repair is already added to this issue' do
      let(:issue) { create(:issue, status_category: :open) }
      let(:device_failure_category) { create(:device_failure_category, name: "akku") }
      let(:device_model) { create(:device_model, name: "iPhone 11") }
      let(:repair_set) { create(:repair_set, device_failure_category:, device_model:) }
      let(:repair_set_entry) { create(:repair_set_entry, repair_set:, article:) }
      let(:repair_set_entry_second) { create(:repair_set_entry, repair_set:, article:) }

      let!(:issue_entry) { create(:issue_entry, issue:, category: :repair_set, repair_set_entry:) }
      let!(:issue_entry_second) do
        create(:issue_entry, issue:, category: :repair_set,
                             repair_set_entry: repair_set_entry_second)
      end

      let!(:text_issue_entry) { create(:issue_entry, article_name: "fooo", issue:, category: :text) }
      let!(:rabatt) { create(:issue_entry, article_name: "fooo", issue:, category: :rabatt) }

      it 'will remove all issue_entries and keep other no repairset entries' do
        expect { subject }.to change { IssueEntry.count }.by(-2)
        expect(subject).to be_success
      end
    end
  end
end
