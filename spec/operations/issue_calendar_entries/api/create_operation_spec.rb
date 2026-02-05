RSpec.describe IssueCalendarEntries::Api::CreateOperation, type: :api_operation do
  describe "#call" do
    subject(:call) do
      described_class.call(params:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:date_start_at) { 10.minutes.from_now.iso8601 }
    let(:date_end_at) { 100.minutes.from_now.iso8601 }
    let(:start_at) { date_start_at.to_s }
    let(:end_at) { date_end_at.to_s }

    let(:device_failure_category) { create(:device_failure_category, name: "akku") }
    let(:device_model) { create(:device_model, name: "iPhone 11") }
    let!(:device_color) { create(:device_color, name: "black", device_model:) }
    let(:repair_set) { create(:repair_set, device_failure_category:, device_model:, device_color:) }
    let!(:merchant_id) { demo_user.account.merchant.id }

    context 'Missing params' do
      let(:params) do
        {
          entry_type: "repair",
          start_at:,
          end_at:,
          notes: "Some notes",
          customer: {
            first_name: "John",
            last_name: "Doe",
            email: "m@m.de"

          },
          repair_set_id: nil,
          merchant_id:
        }
      end

      let!(:customer) { create(:customer, email: "m@m.de") }
      it 'returns failure' do
        expect { subject }.to change { Customer.count }.by(0)
        expect(subject).to be_failure
        expect(subject.failure.messages.first.to_h).to include(
          { customer: { mobile_number: ["must be filled"] } }
        )
        expect(subject.failure.messages.second.to_h).to include(
          { repair_set_id: ["must be filled"] }
        )
      end
    end

    context 'Create issue calendar entry with valid params' do
      let(:params) do
        {
          entry_type: "repair",
          start_at:,
          end_at:,
          notes: "Some notes",
          customer: {
            first_name: "John",
            last_name: "Doe",
            email: "m@m.de",
            mobile_number: "123456789"
          },
          repair_set_id: repair_set.id,
          merchant_id:
        }
      end

      it 'returns  success and create an issue as well as new customer' do
        expect { subject }.to change { Customer.count }.by(1).and change { Issue.count }.by(1)
        expect(subject).to be_success
        expect(subject.success.calendarable).to be_a(Issue)
        expect(subject.success.calendarable).to be_persisted
        expect(subject.success).to have_attributes(
          {
            calendarable_id: Issue.last.id,
            calendarable_type: "Issue"
          }
        )
        expect(subject.success.end_at).to eq(date_end_at)
        expect(subject.success.start_at).to eq(date_start_at)
        expect(subject.success.calendarable.reload.device).to be_a(Device)
        expect(subject.success.calendarable.reload.device.device_model).to eq(device_model)
      end
    end

    context 'Create issue calendar entry with valid params without color for device should pick first color black' do
      let(:repair_set) { create(:repair_set, device_failure_category:, device_model:, device_color: nil) }
      let(:params) do
        {
          entry_type: "repair",
          start_at:,
          end_at:,
          notes: "Some notes",
          customer: {
            first_name: "John",
            last_name: "Doe",
            email: "m@m.de",
            mobile_number: "123456789"
          },
          repair_set_id: repair_set.id,
          merchant_id:
        }
      end

      it 'returns  success and create an issue as well as new customer' do
        expect { subject }.to change { Customer.count }.by(1).and change { Issue.count }.by(1).and(
          change { Device.count }.by(1)
        ).and(change { Comment.count }.by(1))
        expect(subject).to be_success
        expect(subject.success.calendarable).to be_a(Issue)
        expect(subject.success.calendarable).to be_persisted
        expect(subject.success).to have_attributes(
          {
            calendarable_id: Issue.last.id,
            calendarable_type: "Issue",
            source: "api"
          }
        )
        expect(subject.success.end_at).to eq(date_end_at)
        expect(subject.success.start_at).to eq(date_start_at)
        expect(subject.success.notes).to eq("Some notes")
        expect(Comment.last.body).to eq("Kundennotiz: Some notes")
        expect(subject.success.calendarable.reload.device).to be_a(Device)
        expect(subject.success.calendarable.reload.device.device_model).to eq(device_model)
        expect(subject.success.calendarable.reload.device.device_color.name).to eq("black")
        expect(subject.success.calendarable.reload.source).to eq("api")
      end
    end

    context 'existing email and phone' do
      let(:params) do
        {
          entry_type: "repair",
          start_at:,
          end_at:,
          notes: "Some notes",
          customer: {
            first_name: "John",
            last_name: "Doe",
            email: "m@m.de",
            mobile_number: "0123456789"
          },
          repair_set_id: repair_set.id,
          merchant_id:
        }
      end

      let!(:customer) do
        create(
          :customer, email: "m@m.de", mobile_number: "0123456789",
                     merchant_id:
        )
      end
      it 'returns failure' do
        expect { subject }.to change { Customer.count }.by(0).and change { Issue.count }.by(1).and(
          change { Device.count }.by(1)
        ).and(change { Comment.count }.by(1))
        expect(subject).to be_success
      end
    end
  end
end
