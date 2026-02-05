RSpec.describe CalendarEntries::CancelOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(calendar_entry:, notify_customer: false)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:issue) { create(:issue) }
      let(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.now,
               end_at: 1.hour.from_now,
               status: :open)
      end

      it 'returns successfull result' do
        expect { subject }.to change { CalendarEntry.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success).to be_persisted
        expect(subject.success).to be_status_canceld
      end
    end
  end
end
