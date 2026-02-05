RSpec.describe IssueEntries::UpdatePriceOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(issue_id: issue.id, issue_entry_ids:, user_given_set_price:)
    end

    include_context "setup demo account and user"

    let(:article) { create(:article, default_retail_price: 114.51) }
    let(:article2) { create(:article, default_retail_price: 64.51) }
    let(:article3) { create(:article, default_retail_price: 94.51) }
    let(:customer_id) { create(:customer).id }
    let(:device_received) { true }
    let(:device_model) { create(:device_model, name: "iPhone 10") }
    let(:device_color) { create(:device_color, name: "black") }
    let(:device) { create(:device, device_model:, device_color:) }
    let(:device_failure_category) { create(:device_failure_category, name: "micro") }
    let(:device_failure_category_two) { create(:device_failure_category, name: "Display") }

    context 'When updating price for selected repair set entries matching specific device color and failure category' do
      let(:repair_set_to_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color1) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article:)
      end
      let!(:repair_set_entry_with_color2) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article: article2)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 200 }
      let!(:existing_issue_entry1) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color1,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: 20
        )
      end
      let!(:existing_issue_entry2) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color2,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article: article2,
                        tax: 19,
                        qty: 2,
                        price: 10
        )
      end

      let(:issue_entry_ids) { [existing_issue_entry1.id] }

      it 'correctly updates the prices of matching entries without altering non-involved entries' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(2)
        expect(existing_issue_entry1.reload.price).to eq(100)
        expect(existing_issue_entry2.reload.price).to eq(50)
      end
    end

    context 'When updating price without any entries provided' do
      let(:repair_set_to_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color1) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article:)
      end
      let!(:repair_set_entry_with_color2) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article: article2)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 100 }
      let!(:existing_issue_entry1) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color1,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: 20
        )
      end
      let!(:existing_issue_entry2) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color2,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article: article2,
                        tax: 19,
                        qty: 2,
                        price: 10
        )
      end
      let!(:text_entry) do
        create(
          :issue_entry, issue:,
                        category: :text,
                        article_name: "Some text",
                        tax: 19,
                        qty: 2,
                        price: 80
        )
      end

      let(:issue_entry_ids) { [] }

      it 'correctly updates the prices of all entries' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(3)
        expect(existing_issue_entry1.reload.price).to eq(10)
        expect(existing_issue_entry2.reload.price).to eq(5)
        expect(text_entry.reload.price).to eq(40)
      end
    end

    context 'When multiple entries are present but only one entry is selected' do
      let(:repair_set_to_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end

      let!(:repair_set_entry_with_color1) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article:)
      end
      let!(:repair_set_entry_with_color2) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article: article2)
      end

      let(:repair_set_not_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair not to be updated")
      end
      let!(:repair_set_not_be_updated_set_entry) do
        create(:repair_set_entry, repair_set: repair_set_not_be_updated, article: article3)
      end

      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 200 }
      let!(:existing_issue_entry1) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color1,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: 20
        )
      end
      let!(:existing_issue_entry2) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color2,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article: article2,
                        tax: 19,
                        qty: 2,
                        price: 10
        )
      end

      let!(:not_to_be_updated_issue_entry) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_not_be_updated_set_entry,
                        sort_repair_set_id: repair_set_not_be_updated.id,
                        article: article3,
                        tax: 19,
                        qty: 2,
                        price: 500
        )
      end

      let(:issue_entry_ids) { [existing_issue_entry1.id] }

      it 'updates the prices of entries from the matching repair set and leaves entries from non-matching sets unchanged' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(existing_issue_entry1.reload.price).to eq(100)
        expect(existing_issue_entry2.reload.price).to eq(50)
        expect(not_to_be_updated_issue_entry.reload.price).to eq(500)
      end
    end

    context 'When setting price to zero' do
      let(:repair_set_to_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end

      let!(:repair_set_entry_with_color1) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article:)
      end
      let!(:repair_set_entry_with_color2) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article: article2)
      end

      let(:repair_set_not_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair not to be updated")
      end
      let!(:repair_set_not_be_updated_set_entry) do
        create(:repair_set_entry, repair_set: repair_set_not_be_updated, article: article3)
      end

      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 0 }
      let!(:existing_issue_entry1) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color1,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: 20
        )
      end
      let!(:existing_issue_entry2) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color2,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article: article2,
                        tax: 19,
                        qty: 2,
                        price: 10
        )
      end

      let!(:not_to_be_updated_issue_entry) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_not_be_updated_set_entry,
                        sort_repair_set_id: repair_set_not_be_updated.id,
                        article: article3,
                        tax: 19,
                        qty: 2,
                        price: 500
        )
      end

      let(:issue_entry_ids) { [] }

      it 'updates the prices of entries from the matching repair set and leaves entries from non-matching sets unchanged' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(existing_issue_entry1.reload.price).to eq(0)
        expect(existing_issue_entry2.reload.price).to eq(0)
        expect(not_to_be_updated_issue_entry.reload.price).to eq(0)
      end
    end

    context 'When updating price providing 2 selected entries from the same repair set' do
      let(:repair_set_to_be_updated) do
        create(:repair_set, device_failure_category: device_failure_category_two,
                            device_model:, device_color:, name: "repair set with color")
      end
      let!(:repair_set_entry_with_color1) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article:)
      end
      let!(:repair_set_entry_with_color2) do
        create(:repair_set_entry, repair_set: repair_set_to_be_updated, article: article2)
      end
      let(:issue) do
        create(:issue, status: :draft, device_id: device.id,
                       input_device_failure_categories: [
                         device_failure_category.name,
                         device_failure_category_two.name
                       ])
      end

      let(:user_given_set_price) { 200 }
      let!(:existing_issue_entry1) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color1,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article:,
                        tax: 19,
                        qty: 1,
                        price: 20
        )
      end
      let!(:existing_issue_entry2) do
        create(
          :issue_entry, issue:,
                        category: :repair_set,
                        repair_set_entry: repair_set_entry_with_color2,
                        sort_repair_set_id: repair_set_to_be_updated.id,
                        article: article2,
                        tax: 19,
                        qty: 2,
                        price: 10
        )
      end

      let(:issue_entry_ids) { [existing_issue_entry1.id, existing_issue_entry2] }

      it 'correctly updates the prices of matching entries without altering non-involved entries' do
        expect { subject }.to change { IssueEntry.count }.by(0)
        expect(subject).to be_success
        expect(issue.issue_entries.count).to eq(2)
        expect(existing_issue_entry1.reload.price).to eq(100)
        expect(existing_issue_entry2.reload.price).to eq(50)
      end
    end
  end
end
