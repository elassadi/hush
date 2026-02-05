# spec/models/interval_tree/builder_spec.rb
require 'rails_helper'

RSpec.describe IntervalTree::Builder, type: :model do
  let(:entries) do
    [
      { start_at: Time.zone.local(2024, 10, 21, 9, 0), end_at: Time.zone.local(2024, 10, 21, 10, 0) },
      { start_at: Time.zone.local(2024, 10, 21, 11, 0), end_at: Time.zone.local(2024, 10, 21, 12, 0) },
      { start_at: Time.zone.local(2024, 10, 21, 14, 0), end_at: Time.zone.local(2024, 10, 21, 15, 0) }
    ]
  end

  it 'builds a tree with the correct root node' do
    root = IntervalTree::Builder.build_tree(entries)

    expect(root.start_at).to eq(entries[0][:start_at])
    expect(root.end_at).to eq(entries[0][:end_at])
    expect(root.max_end).to eq(entries[2][:end_at]) # max_end should be the largest end_at
  end

  it 'inserts nodes correctly in the tree' do
    root = IntervalTree::Builder.build_tree(entries)

    expect(root.right.start_at).to eq(entries[1][:start_at])
    expect(root.right.end_at).to eq(entries[1][:end_at])
    expect(root.right.right.start_at).to eq(entries[2][:start_at])
  end
end
