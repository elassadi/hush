RSpec.describe IssueEntries::AddMatchingRepairSetOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue:)
    end

    include_context "setup demo account and user"

    let(:article) { create(:article) }
    let(:article) { create(:article) }
    let(:customer_id) { create(:customer).id }
    let(:device_received) { true }
    let(:device_model) { create(:device_model, name: "iPhone 10") }
    let(:device_color) { create(:device_color, name: "black") }
    let(:device) { create(:device, device_model:, device_color:) }
    let(:device_failure_category) { create(:device_failure_category, name: "micro") }
    let(:device_failure_category_two) { create(:device_failure_category, name: "Display") }

    context 'With no device  or no failure category' do
      let(:repair_set_with_color) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color) do
        create(:repair_set_entry, repair_set: repair_set_with_color, article:)
      end
      let(:issue) do
        create(:issue, status: :draft, device: nil,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_failure
      end
    end

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

      # let(:existing_repair_set_entry) { create(:repair_set_entry, repair_set: existing_repair_set, article:) }
      # let!(:existing_issue_entry) { create(:issue_entry, issue:, category: :repair_set,
      #   repair_set_entry: existing_repair_set_entry)
      # }

      it 'match the set and add set entries' do
        expect { subject }.to change { IssueEntry.count }.by(1)
        expect(subject).to be_success
      end
    end

    context 'With multiple repairset with no color and failure category' do
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
