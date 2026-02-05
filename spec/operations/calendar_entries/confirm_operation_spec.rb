RSpec.describe CalendarEntries::ConfirmOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(calendar_entry:, notify_customer:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    context 'when data valid ' do
      let(:issue) { create(:issue) }
      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.now,
               end_at: 1.hour.from_now,
               status: :open)
      end
      let(:notify_customer) { false }

      it 'returns successfull result' do
        expect { subject }.to change { CalendarEntry.count }.by(0)
        expect(subject).to be_success
        expect(subject.success).to be_a(CalendarEntry)
        expect(subject.success).to be_persisted
        expect(subject.success.confirmed?).to be_truthy
      end
    end

    context 'when data valid and notifcation on' do
      let(:issue) { create(:issue) }
      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.now,
               end_at: 1.hour.from_now,
               status: :open)
      end
      let(:notify_customer) { true }

      it 'returns successfull result' do
        allow(Event).to receive(:broadcast)
        expect { subject }.to change { CalendarEntry.count }.by(0)
        expect(subject).to be_success
        expect(subject.success.confirmed?).to be_truthy
        expect(Event).to have_received(:broadcast).with(:calendar_entry_confirmed,
                                                        calendar_entry_id: subject.success.id, notify_customer: true)
      end
    end

    context 'when data valid' do
      let(:issue) { create(:issue, source: :api, owner: create(:user, :public_api)) }
      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.now,
               end_at: 1.hour.from_now,
               status: :open, source: "api")
      end
      let(:notify_customer) { true }

      it 'returns successfull result and set owner to demo_user' do
        allow(Event).to receive(:broadcast)
        expect(subject).to be_success
        expect(subject.success.confirmed?).to be_truthy
        expect(Event).to have_received(:broadcast).with(:calendar_entry_confirmed,
                                                        calendar_entry_id: subject.success.id, notify_customer: true)
        expect(subject.success.owner).to eq(demo_user)
        expect(subject.success.calendarable.owner).to eq(demo_user)
      end
    end
  end
end
