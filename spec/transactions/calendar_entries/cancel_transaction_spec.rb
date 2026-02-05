RSpec.describe CalendarEntries::CancelTransaction do
  describe "#call" do
    subject(:call) do
      described_class.call(calendar_entry_id: calendar_entry.id, notify_customer: false)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:operation) do
      instance_double(CalendarEntries::CancelOperation)
    end

    before do
      allow(CalendarEntries::CancelOperation).to receive(:new)
        .with({ calendar_entry:, notify_customer: false })
        .and_return(operation)
    end

    context "with valid data " do
      let(:issue) { create(:issue) }
      let(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.now,
               end_at: 1.hour.from_now)
      end

      it "returns success result" do
        expect(operation).to receive(:call).and_return(Dry::Monads::Success(calendar_entry))
        expect(call).to be_success
        expect(call.success).to eq(calendar_entry)
      end
    end
  end
end
