RSpec.describe CalendarEntries::AvailableSlotsOperation do
  describe "#call" do
    subject(:operation) do
      described_class.call(start_date:, end_date:, slot_duration:, merchant_id:,
                           use_standard_slot_search: true)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:issue) { create(:issue) }
    let(:merchant_id) { Current.user.branch.id }

    let!(:business_hours) do
      create(:business_hour, jsonable: Current.user.branch,
                             day: 'mo_to_fr', start_time: '09:00', end_time: '18:00')
      create(:business_hour, jsonable: Current.user.branch,
                             day: 'sa', start_time: '09:00', end_time: '12:00')
    end

    let(:o_settings) do
      {
        confirmed: 1,
        unconfirmed: 1
      }
    end

    before do
      allow(described_class).to receive(:new).and_call_original
      allow_any_instance_of(described_class).to receive(:max_appointment_per_slot_setting).and_return(o_settings)
    end

    context 'when data valid and entry are not confirmed and overlaping is allowed once' do
      # saturn 7th september 2024
      # we have an apointement from 11:00 to 12:00 which is not confirmed
      # we expect to have 7 slots from 9:00 to 12:00, in 15 Minutes steps overlapping is allowed
      # with a maximum of 2 unconfirmed appointment per slot and 1 confirmed appointment per slot

      let(:ref_date) { Date.new(2024, 9, 7) }
      let(:o_settings) do
        {
          confirmed: 1,
          unconfirmed: 2
        }
      end

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               start_at: ref_date.to_time.change(hour: 11, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end
      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 0.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(7)
        expect(subject.success.first).to be_a(Hash)
        expect(subject.success.first[:start]).to eq(ref_date.to_time.change(hour: 9, min: 0))
        expect(subject.success.first[:end]).to eq(ref_date.to_time.change(hour: 10, min: 30))
        expect(subject.success.last[:start]).to eq(ref_date.to_time.change(hour: 10, min: 30))
        expect(subject.success.last[:end]).to eq(ref_date.to_time.change(hour: 12, min: 0))
      end
    end

    context 'when data valid and entry are not confirmed and no verlapping allowed' do
      # saturn 7th september 2024
      # we allow unconfirmed and confirmed appointment each per slot and no overlapping
      let(:ref_date) { Date.new(2024, 9, 7) }

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
               start_at: ref_date.to_time.change(hour: 11, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end
      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(3)
        expect(subject.success.first).to be_a(Hash)
        expect(subject.success.first[:start]).to eq(ref_date.to_time.change(hour: 9, min: 0))
        expect(subject.success.first[:end]).to eq(ref_date.to_time.change(hour: 10, min: 30))
        expect(subject.success.last[:start]).to eq(ref_date.to_time.change(hour: 9, min: 30))
        expect(subject.success.last[:end]).to eq(ref_date.to_time.change(hour: 11, min: 0))
      end
    end

    context 'when data valid and user calendar entry ' do
      # saturn 7th september 2024
      let(:ref_date) { Date.new(2024, 9, 7) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 11, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end
      let!(:user_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'user',
               category: 'holiday',
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 10, min: 0))
      end
      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(3)
        expect(subject.success.first).to be_a(Hash)
        expect(subject.success.first[:start]).to eq(ref_date.to_time.change(hour: 9, min: 0))
        expect(subject.success.first[:end]).to eq(ref_date.to_time.change(hour: 10, min: 30))
        expect(subject.success.last[:start]).to eq(ref_date.to_time.change(hour: 9, min: 30))
      end
    end

    context 'when data valid and user calendar entry are confirmed' do
      # saturn 7th september 2024
      let(:ref_date) { Date.new(2024, 9, 7) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 11, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end
      let!(:user_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'user',
               category: 'holiday',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 10, min: 0))
      end
      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(3)
        expect(subject.success.first).to be_a(Hash)
        expect(subject.success.first[:start]).to eq(ref_date.to_time.change(hour: 9, min: 0))
        expect(subject.success.first[:end]).to eq(ref_date.to_time.change(hour: 10, min: 30))
        expect(subject.success.last[:start]).to eq(ref_date.to_time.change(hour: 9, min: 30))
        expect(subject.success.last[:end]).to eq(ref_date.to_time.change(hour: 11, min: 0))
      end
    end

    context 'when data valid and user calendar entry are confirmed but overlapping is allowed' do
      let(:o_settings) do
        {
          confirmed: 0,
          unconfirmed: 0
        }
      end

      # saturn 7th september 2024
      let(:ref_date) { Date.new(2024, 9, 7) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(7)
      end
    end

    context 'when data valid and calendar entry are confirmed' do
      # Monday 10th september 2024
      let(:ref_date) { Date.new(2024, 9, 10) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
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
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(34)
      end
    end

    context 'when data are from another account' do
      # saturn 7th september 2024
      let(:ref_date) { Date.new(2024, 9, 7) }

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end
      let!(:second_calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               account: create(:account),
               entry_type: 'repair',
               confirmed_at: Time.zone.now,
               start_at: ref_date.to_time.change(hour: 9, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
      end

      let(:start_date) { ref_date }
      let(:end_date) { ref_date + 1.day }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(0)
      end
    end

    context 'when data valid and entry are not confirmed and overlaping is allowed once but blocker is set' do
      # saturn 7th september 2024
      # we have an apointement from 11:00 to 12:00 which is not confirmed
      # we have a blocker for 2 days from 7th to 9th september 2024
      # we expect to have 0 slots

      let(:ref_date) { Date.new(2024, 9, 7) }
      let(:o_settings) do
        {
          confirmed: 1,
          unconfirmed: 2
        }
      end

      let!(:calendar_entry) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: 'repair',
               start_at: ref_date.to_time.change(hour: 11, min: 0),
               end_at: ref_date.to_time.change(hour: 12, min: 0))
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
      let(:end_date) { ref_date + 0.days }
      let(:slot_duration) { 90.minutes }
      it 'returns successfull result' do
        # expect { subject }.to change { Customer.count }.by(1).and change { Address.count }.by(1)
        expect(subject).to be_success
        expect(subject.success).to be_an(Array)
        expect(subject.success.count).to eq(0)
      end
    end
  end
end
