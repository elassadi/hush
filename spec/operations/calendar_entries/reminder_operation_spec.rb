RSpec.describe CalendarEntries::ReminderOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(calendar_entry:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:issue) { create(:issue) }
    let!(:calendar_entry) do
      create(:calendar_entry,
             calendarable: issue,
             entry_type: "repair",
             start_at:,
             reminded_at:,
             end_at: 2.days.from_now,
             status: :open)
    end
    let(:reminded_at) { nil }

    context 'when the booking reminder is enabled and the event is one day before the scheduled start time' do
      let!(:start_at) { 23.hours.from_now }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: true,
                                 booking_reminder_frequency: ["one_day_before"])
      end
      it 'broadcast a reminder request successfully' do
        allow(Event).to receive(:broadcast)
        expect(subject).to be_success
        expect(Event).to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                        calendar_entry_id: calendar_entry.id,
                                                        frequency: "one_day_before")
      end
    end

    context 'when the booking reminder is enabled and
     the event is one day before the scheduled start time but too late to remind' do
      let!(:start_at) { 21.hours.from_now }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: true,
                                 booking_reminder_frequency: ["one_day_before"])
      end
      it 'doesnt broadcast ' do
        allow(Event).to receive(:broadcast)
        expect(subject.success[:frequency]).to eq(:no_reminder_due)
        expect(Event).not_to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                            calendar_entry_id: calendar_entry.id)
      end
    end

    context "when the booking reminder is enabled and the event is 45 minutes before the scheduled start time " \
            "and frequenz is set to day" do
      let!(:start_at) { 45.minutes.from_now }
      let(:reminded_at) { 23.hours.ago }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: true,
                                 booking_reminder_frequency: ["one_day_before"])
      end
      it 'doesnt broadcast a reminder and return failure' do
        allow(Event).to receive(:broadcast)
        expect(subject.success[:frequency]).to eq(:no_reminder_due)
        expect(Event).not_to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                            calendar_entry_id: calendar_entry.id)
      end
    end

    context "when the booking reminder is enabled and the event is 45 minutes before the scheduled start time " \
            "and frequenz is set to day and hour" do
      let!(:start_at) { 50.minutes.from_now }
      let(:reminded_at) { 23.hours.ago }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: true,
                                 booking_reminder_frequency: %w[one_day_before one_hour_before])
      end
      it 'should broadcast a reminder and return success' do
        allow(Event).to receive(:broadcast)
        expect(subject).to be_success
        expect(Event).to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                        calendar_entry_id: calendar_entry.id,
                                                        frequency: "one_hour_before")
      end
    end

    context "when the booking reminder is enabled and the event is 70 minutes before the scheduled start time " \
            "and frequenz is set to day and hour" do
      let!(:start_at) { 70.minutes.from_now }
      # let(:reminded_at) { Time.zone.now - 23.hour }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: true,
                                 booking_reminder_frequency: %w[one_day_before one_hour_before])
      end
      it 'should broadcast a reminder and return success' do
        allow(Event).to receive(:broadcast)
        expect(subject.success[:frequency]).to eq(:no_reminder_due)
        expect(Event).not_to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                            calendar_entry_id: calendar_entry.id)
      end
    end

    context 'when the booking reminder is  not enabled' do
      let!(:start_at) { 23.hours.from_now }

      let!(:booking_settings) do
        create(:booking_setting, booking_reminder_enabled: false,
                                 booking_reminder_frequency: ["one_day_before"])
      end
      it 'doesnt broadcast a reminder and return failure' do
        allow(Event).to receive(:broadcast)
        expect(subject).to be_failure
        expect(Event).not_to have_received(:broadcast).with(:calendar_entry_reminder_requested,
                                                            calendar_entry_id: calendar_entry.id)
      end
    end
  end
end
