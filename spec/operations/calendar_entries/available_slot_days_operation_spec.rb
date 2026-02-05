RSpec.describe CalendarEntries::AvailableSlotsOperation do
  describe "#call" do
    subject(:call) do
      described_class.call(start_date:, end_date:, slot_duration:,
                           merchant_id:, days_only: true)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:issue) { create(:issue) }
    let(:merchant_id) { Current.user.branch.id }
    let!(:business_hourr) do
      create(:business_hour, jsonable: Current.user.branch,
                             day: 'mo_to_fr', start_time: '09:00', end_time: '18:00')
    end

    let(:o_settings) do
      {
        confirmed: 0,
        unconfirmed: 1
      }
    end

    before do
      allow(described_class).to receive(:new).and_call_original
      allow_any_instance_of(described_class).to receive(:max_appointment_per_slot_setting).and_return(o_settings)
    end

    context 'when data valid and user calendar entry are confirmed' do
      # we allow only one unconfirmed entry and one confirmed entry per slot
      let(:o_settings) do
        {
          confirmed: 1,
          unconfirmed: 1
        }
      end

      # Monday 10th september 2024
      let(:ref_date) { Date.new(2024, 9, 10) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 18, min: 0))
      end
      let!(:second_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: (ref_date + 1.day).to_time.change(hour: 14, min: 0),
               end_at: (ref_date + 1.day).to_time.change(hour: 18, min: 0))
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 2.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(2)
      end
    end

    context 'when data valid and user calendar entry are confirmed' do
      # Monday 10th september 2024
      let(:ref_date) { Date.new(2024, 9, 10) }

      # allow overlap of confirmed entries
      let(:o_settings) do
        {
          confirmed: 2,
          unconfirmed: 1
        }
      end

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 18, min: 0))
      end
      let!(:second_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: (ref_date + 1.day).to_time.change(hour: 14, min: 0),
               end_at: (ref_date + 1.day).to_time.change(hour: 18, min: 0))
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 2.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result and allow overlaps of first day schedules' do
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(3)
      end
    end

    context 'when data valid and user calendar entry are confirmed' do
      # Monday 10th september 2024
      let(:ref_date) { Date.new(2024, 9, 10) }

      # allow overlap of confirmed entries
      let(:o_settings) do
        {
          confirmed: 1,
          unconfirmed: 1
        }
      end

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 18, min: 0))
      end
      let!(:second_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: (ref_date + 1.day).to_time.change(hour: 14, min: 0),
               end_at: (ref_date + 1.day).to_time.change(hour: 18, min: 0))
      end
      let!(:calendar_entry_third) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               start_at: (ref_date + 2.days).to_time.change(hour: 9, min: 0),
               end_at: (ref_date + 2.days).to_time.change(hour: 18, min: 0))
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 2.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(1)
      end
    end

    context 'all day blocker is set ' do
      # Monday 10th september 2024
      let(:ref_date) { Date.new(2024, 9, 10) }

      # allow overlap of confirmed entries
      let(:o_settings) do
        {
          confirmed: 1,
          unconfirmed: 1
        }
      end

      let!(:blocker) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'blocker',
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 9, min: 0) + 2.days,
               all_day: true,
               category: 'holiday')
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 2.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(1)
        expect(subject.success.first).to eq(ref_date + 2.days)
      end
    end
  end
end
