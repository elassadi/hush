RSpec.describe IssueCalendarEntries::UpdateOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(
        calendar_entry:,
        entry_type:,
        start_at:,
        end_at:,
        category:,
        event_color:,
        notes:,
        all_day:
      )
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let!(:calendar_entry) do
      create(:calendar_entry,
             calendarable: customer,
             entry_type:,
             start_at: 20.minutes.from_now.iso8601.to_s,
             end_at: 100.minutes.from_now.iso8601.to_s)
    end
    let(:start_at) { 10.minutes.from_now.iso8601.to_s }
    let(:end_at) { 100.minutes.from_now.iso8601.to_s }
    let(:category) { nil }
    let(:event_color) { nil }
    let(:confirmed_at) { Time.zone.now }
    let(:notes) { "Some notes" }
    let(:all_day) { false }

    context 'update issue calendar entry with valid data for repair schedule' do
      let(:entry_type) { "repair" }
      let!(:customer) { create(:customer, email: "m@m.de") }

      it 'update the calendar entry ' do
        expect { subject }.to change { CalendarEntry.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success.start_at).to eq(start_at)
      end
    end

    context 'update issue calendar entry with  non valid data' do
      let(:entry_type) { "repair" }
      let!(:customer) { create(:customer, email: "m@m.de") }

      let(:end_at) { 10.minutes.from_now.iso8601.to_s }
      let(:start_at) { 100.minutes.from_now.iso8601.to_s }
      it 'update the calendar entry ' do
        expect(subject).to be_failure
        expect(subject.failure.errors.details[:start_at]).to include(a_hash_including(error: :less_than))
      end
    end
  end
end
