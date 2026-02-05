RSpec.describe IssueCalendarEntries::CreateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(
        entry_type:,
        calendarable_id:,
        calendarable_type:,
        start_at:,
        end_at:,
        category:,
        event_color:,
        confirmed_at:,
        notes:,
        all_day:,
        selected_repair_set_id:,
        merchant_id:
      )
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:calendarable_id) { customer.id }
    let(:calendarable_type) { "Customer" }
    let(:start_at) { 10.minutes.from_now.iso8601.to_s }
    let(:end_at) { 100.minutes.from_now.iso8601.to_s }
    let(:category) { nil }
    let(:event_color) { nil }
    let(:confirmed_at) { Time.zone.now }
    let(:notes) { "Some notes" }
    let(:all_day) { false }
    let(:device_failure_category) { create(:device_failure_category, name: "akku") }
    let(:device_model) { create(:device_model, name: "iPhone 11") }
    let!(:device_color) { create(:device_color, name: "black", device_model:) }
    let(:repair_set) { create(:repair_set, device_failure_category:, device_model:) }
    let(:selected_repair_set_id) { repair_set.id }
    let!(:merchant_id) { demo_user.account.merchant.id }

    context 'Create issue calendar entry with valid data for repair schedule' do
      let(:entry_type) { "repair" }
      let!(:customer) { create(:customer, email: "m@m.de") }
      it 'creates a new repair calendar entry and a issue' do
        expect { subject }.to change { CalendarEntry.count }.by(1).and(
          change { Issue.count }.by(1)
        )
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.account).to eq(demo_user.account)
        expect(subject.success.calendarable).to eq(Issue.last)
        expect(subject.success.calendarable.source).to eq("backend")
        expect(subject.success.selected_repair_set_id).to eq(repair_set.id)
        expect(subject.success.merchant_id).to eq(merchant_id)
        expect(subject.success.source).to eq("backend")
      end
    end

    context 'Create issue calendar entry with valid data for regular schedule' do
      let(:entry_type) { "regular" }
      let!(:customer) { create(:customer, email: "m@m.de") }
      it 'creates a new regular calendar entry and a issue' do
        expect { subject }.to change { CalendarEntry.count }.by(1).and(
          change { Issue.count }.by(1)
        )
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.account).to eq(Current.user.account)
        expect(subject.success.calendarable).to eq(Issue.last)
      end
    end

    context 'Create user calendar entry with valid params' do
      let(:user) { create(:user) }
      let(:calendarable_id) { user.id }
      let(:calendarable_type) { "User" }
      let(:entry_type) { "user" }
      let(:category) { "holiday" }

      it 'creates a new calendar entry with' do
        expect { subject }.to change { CalendarEntry.count }.by(1).and(
          change { Issue.count }.by(0)
        )
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.account).to eq(Current.user.account)
        expect(subject.success.calendarable).to eq(user)
      end
    end

    context 'Create issue calendar entry with valid data for regular schedule for existing issue' do
      let(:entry_type) { "repair" }
      let(:customer) { create(:customer, email: "m@m.de") }
      let!(:issue) { create(:issue, customer:, status_category: :open) }
      it 'creates a new calendar entry and assign the existing issue' do
        expect { subject }.to change { CalendarEntry.count }.by(1).and(
          change { Issue.count }.by(1)
        )
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.account).to eq(Current.user.account)
        # expect(subject.success.calendarable).to eq(issue)
      end
    end

    context 'Create issue calendar entry with valid data for regular schedule for existing closed issue' do
      let(:entry_type) { "repair" }
      let(:customer) { create(:customer, email: "m@m.de") }
      let!(:issue) { create(:issue, customer:, status_category: :done) }
      it 'creates new issue for the new calendar entry' do
        expect { subject }.to change { CalendarEntry.count }.by(1).and(
          change { Issue.count }.by(1)
        )
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.account).to eq(Current.user.account)
        expect(subject.success.calendarable).to eq(Issue.last)
      end
    end

    context 'with an unknow merchant' do
      let(:entry_type) { "repair" }
      let!(:customer) { create(:customer, email: "m@m.de") }
      let!(:merchant_id) { 100 }
      it 'returns a failure' do
        expect { subject }.to change { CalendarEntry.count }.by(0)
        expect(subject).to be_failure
        expect(subject.failure).to eq("Merchant/Branch not found")
      end
    end
  end
end
