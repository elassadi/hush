RSpec.describe Issues::UpdateOperation do
  include_context "setup system user"
  include_context "setup demo account and user"

  let(:issue) { create(:issue, status: :draft) }

  describe "#call" do
    subject(:call) do
      described_class.call(
        issue:, device_id:, customer_id:, input_device_failure_categories:, device_accessories_list:,
        device_received:
      )
    end
    let(:new_device_model) { create(:device_model, name: "iPhone 11") }
    let(:article) { create(:article) }
    let(:customer_id) { create(:customer).id }
    let(:device_received) { true }
    let(:device_accessories_list) { ["cable"] }

    let(:old_device_model) { create(:device_model, name: "iPhone 10") }
    let(:old_device) { create(:device, device_model: old_device_model) }
    let(:old_device_failure_category) { create(:device_failure_category) }

    let(:issue) do
      create(:issue, status: :draft, device_id: old_device.id,
                     input_device_failure_categories: [old_device_failure_category],
                     device_accessories_list:)
    end

    context 'With no changes ' do
      let(:new_device_failure_category) { old_device_failure_category }
      let(:new_device) { old_device }

      let(:device_id) { old_device.id }
      let(:input_device_failure_categories) { [old_device_failure_category.name] }

      it 'returns successfull result and noch changes are made' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(subject.success.input_device_failure_categories).to include(old_device_failure_category.name)
        expect(subject.success.device_id).to eq(old_device.id)
      end
    end

    context 'With changes but no existing set for new device/failure' do
      let(:new_device_failure_category) { create(:device_failure_category) }
      let(:new_device) { create(:device, device_model: new_device_model) }

      let(:device_id) { new_device.id }
      let(:input_device_failure_categories) { [new_device_failure_category.name] }

      let(:repair_set) do
        create(:repair_set, device_failure_category: old_device_failure_category,
                            device_model: old_device_model, name: "old repair set")
      end

      let(:repair_set_entry) do
        create(:repair_set_entry, repair_set:, article:)
      end
      let!(:issue_entry) do
        create(:issue_entry, issue:, category: :repair_set,
                             repair_set_entry_id: repair_set_entry.id)
      end

      it 'returns successfull result and update issue' do
        expect { subject }.to change { IssueEntry.count }.by(-1)
        expect(subject).to be_success
        expect(subject.success.input_device_failure_categories).to include(new_device_failure_category.name)
        expect(subject.success.device_id).to eq(new_device.id)
        expect(subject.success.issue_entries.category_repair_set).to be_empty
      end
    end

    context 'With changes with an existing set for new device/failure' do
      let(:new_device_failure_category) { create(:device_failure_category, name: "wasser-schaden") }
      let(:new_device) { create(:device, device_model: new_device_model) }

      let(:device_id) { new_device.id }
      let(:input_device_failure_categories) { [new_device_failure_category.name] }

      let(:repair_set) do
        create(:repair_set, device_failure_category: new_device_failure_category,
                            device_model: new_device_model, name: "repair set matching issue")
      end

      let!(:repair_set_entry) { create(:repair_set_entry, repair_set:, article:) }

      it 'returns successfull result and update issue' do
        expect { subject }.to change { IssueEntry.count }.by(1)
        expect(subject).to be_success
        expect(subject.success.input_device_failure_categories).to include(new_device_failure_category.name)
        expect(subject.success.device_id).to eq(new_device.id)
        expect(subject.success.issue_entries.category_repair_set.first.repair_set_entry).to eq(repair_set_entry)
      end
    end
  end
end
