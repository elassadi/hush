RSpec.describe CalendarEntries::FetchAllQuery do
  describe "#call" do
    subject(:call) do
      described_class.call(start_at:, end_date:)
    end

    include_context "setup demo account and user"
    include_context "setup system user"

    let(:start_at) { Time.zone.today }
    let(:end_date) { Time.zone.today + 7.days }

    context 'when valid data is provided' do
      let(:issue) { create(:issue) }
      let!(:calendar_entry1) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 1.day,
               end_at: Time.zone.today + 1.day + 1.hour,
               status: :open)
      end

      let!(:calendar_entry2) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 5.days,
               end_at: Time.zone.today + 5.days + 1.hour,
               status: :open)
      end

      it 'returns successful subject with entries in the given date range' do
        expect(subject).to be_success
        expect(subject.success).to include(calendar_entry1, calendar_entry2)
        expect(subject.success).to all(be_a(CalendarEntry))
      end
    end

    context 'when valid data is provided with merchant not belonging to the user' do
      let(:issue) { create(:issue) }
      let(:merchant) { create(:merchant) }
      let!(:calendar_entry1) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 1.day,
               end_at: Time.zone.today + 1.day + 1.hour,
               status: :open,
               merchant_id: merchant.id)
      end

      let!(:calendar_entry2) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 5.days,
               end_at: Time.zone.today + 5.days + 1.hour,
               status: :open)
      end

      it 'returns successful subject with entries in the given date range' do
        expect(subject).to be_success
        expect(subject.success.count).to eq(1)
        expect(subject.success).to include(calendar_entry2)
      end
    end

    context 'when valid data is provided with canceld status' do
      let(:issue) { create(:issue) }
      let(:merchant) { create(:merchant) }
      let!(:calendar_entry1) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 1.day,
               end_at: Time.zone.today + 1.day + 1.hour,
               status: :canceld,
               merchant_id: merchant.id)
      end

      let!(:calendar_entry2) do
        create(:calendar_entry,
               calendarable: issue,
               entry_type: "repair",
               start_at: Time.zone.today + 5.days,
               end_at: Time.zone.today + 5.days + 1.hour,
               status: :canceld)
      end

      it 'returns successful subject with entries in the given date range' do
        expect(subject).to be_success
        expect(subject.success.count).to eq(0)
      end
    end

    context 'when no start_at and end_date are provided' do
      let(:start_at) { nil }
      let(:end_date) { nil }

      it 'returns an empty subject' do
        expect(subject).to be_success
        expect(subject.success).to be_empty
      end
    end
  end
end
