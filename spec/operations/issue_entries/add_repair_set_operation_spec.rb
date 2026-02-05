RSpec.describe IssueEntries::AddRepairSetOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id, repair_set_id: repair_set_with_color.id, user_given_set_price:)
    end

    include_context "setup demo account and user"

    let(:article) { create(:article, default_retail_price: 114.51) }
    let(:article2) { create(:article, default_retail_price: 64.51) }
    let(:customer_id) { create(:customer).id }
    let(:device_received) { true }
    let(:device_model) { create(:device_model, name: "iPhone 10") }
    let(:device_color) { create(:device_color, name: "black") }
    let(:device) { create(:device, device_model:, device_color:) }
    let(:device_failure_category) { create(:device_failure_category, name: "micro") }
    let(:device_failure_category_two) { create(:device_failure_category, name: "Display") }

    context 'With only one reapair set with exact color and failure category' do
      let(:repair_set_with_color) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { nil }

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(1)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(1)
      end
    end

    context 'With only one reapair set with exact color and failure category' do
      let(:repair_set_with_color) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:, qty: 2)
      end
      let!(:repair_set_entry2_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:, qty: 1)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 99.99 }

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(2)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(2)
        expect(issue.price).to eq(user_given_set_price)
      end
    end

    context 'With existing repairsets' do
      let(:user_given_set_price) { 99.99 }
      let(:article) { create(:article, default_retail_price: user_given_set_price) }

      let(:repair_set_with_color) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:, qty: 1)
      end

      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      # existing issue entries

      let!(:existing_issue_entry) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color,
                        sort_repair_set_id: repair_set_with_color.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: user_given_set_price
        )
      end

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(1)
        expect(issue.issue_entries.first.qty).to eq(2)
        expect(issue.price).to eq(user_given_set_price * 2)
      end
    end

    xcontext 'With multiple repairset with no color and failure category' do
      let(:repair_set_one) do
        create(:repair_set, device_failure_category:,
                            device_model:, name: "repair set one")
      end

      let!(:repair_set_entry) do
        create(:repair_set_entry, repair_set: repair_set_one, article:)
      end

      let(:repair_set_two) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, name: "repair set two")
      end
      let!(:repair_set_entry_two) do
        create(:repair_set_entry, repair_set: repair_set_two, article:)
      end

      let(:repair_set_with_color) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(3)
        expect(subject).to be_success
      end
    end
  end
end
