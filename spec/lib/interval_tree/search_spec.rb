require 'rails_helper'

RSpec.describe IntervalTree::Search, type: :model do
  let(:entries) do
    [
      { start_at: Time.zone.local(2024, 10, 21, 9, 0), end_at: Time.zone.local(2024, 10, 21, 10, 0) },
      { start_at: Time.zone.local(2024, 10, 21, 11, 0), end_at: Time.zone.local(2024, 10, 21, 12, 0) },
      { start_at: Time.zone.local(2024, 10, 21, 11, 30), end_at: Time.zone.local(2024, 10, 21, 12, 0) },
      { start_at: Time.zone.local(2024, 10, 21, 14, 0), end_at: Time.zone.local(2024, 10, 21, 15, 0) }
    ]
  end

  it 'finds overlapping intervals' do
    start_time = Time.zone.local(2024, 10, 21, 9, 30)
    end_time = Time.zone.local(2024, 10, 21, 10, 30)

    overlapping_intervals = IntervalTree::Search.build_and_search(entries, start_time, end_time)

    expect(overlapping_intervals.length).to eq(1)
    expect(overlapping_intervals.first.start_at).to eq(entries[0][:start_at])
    expect(overlapping_intervals.first.end_at).to eq(entries[0][:end_at])
  end

  it 'returns empty array if no intervals overlap' do
    start_time = Time.zone.local(2024, 10, 21, 12, 30)
    end_time = Time.zone.local(2024, 10, 21, 13, 30)

    overlapping_intervals = IntervalTree::Search.build_and_search(entries, start_time, end_time)

    expect(overlapping_intervals).to be_empty
  end

  it 'finds multiple overlapping intervals' do
    start_time = Time.zone.local(2024, 10, 21, 9, 0)
    end_time = Time.zone.local(2024, 10, 21, 12, 0)

    overlapping_intervals = IntervalTree::Search.build_and_search(entries, start_time, end_time)

    expect(overlapping_intervals.length).to eq(3)
    expect(overlapping_intervals.map(&:start_at)).to include(
      entries[0][:start_at], entries[1][:start_at], entries[2][:start_at]
    )
  end

  context "when range is more than 24 hours" do
    let(:entries) do
      [
        { start_at: Time.zone.local(2024, 10, 21, 9, 0), end_at: Time.zone.local(2024, 10, 21, 10, 0) },
        { start_at: Time.zone.local(2024, 10, 21, 11, 0), end_at: Time.zone.local(2024, 10, 21, 12, 0) },
        { start_at: Time.zone.local(2024, 10, 21, 11, 30), end_at: Time.zone.local(2024, 10, 21, 12, 0) },
        { start_at: Time.zone.local(2024, 10, 21, 14, 0), end_at: Time.zone.local(2024, 10, 21, 15, 0) },
        { start_at: Time.zone.local(2024, 10, 21, 9, 0), end_at: Time.zone.local(2024, 10, 22, 9, 0) }
      ]
    end

    it 'finds multiple overlapping intervals' do
      start_time = Time.zone.local(2024, 10, 21, 9, 0)
      end_time = Time.zone.local(2024, 10, 21, 12, 0)

      overlapping_intervals = IntervalTree::Search.build_and_search(entries, start_time, end_time)
      expect(overlapping_intervals.length).to eq(4)
      expect(overlapping_intervals.map(&:start_at)).to include(
        entries[0][:start_at], entries[1][:start_at], entries[2][:start_at]
      )
    end
  end
end
