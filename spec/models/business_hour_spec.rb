# spec/models/business_hour_spec.rb
require 'rails_helper'

RSpec.describe BusinessHour, type: :model do
  let(:merchant) { create(:merchant) }
  include_context "setup demo account and user"
  include_context "setup system user"

  describe ".business_hours_hsh" do
    let!(:business_hour_monday) do
      create(:business_hour, metadata: { day: 'mo', start_time: '09:00', end_time: '18:00' }, jsonable: merchant)
    end

    let!(:business_hour_weekend) do
      create(:business_hour, metadata: { day: 'mo_to_fr', start_time: '09:00', end_time: '18:00' }, jsonable: merchant)
    end

    it "returns a correct array for a single day" do
      expect(merchant.business_hours_hsh).to eq([
                                                  nil, # Sunday
                                                  { start: '09:00', end: '18:00' }, # Monday
                                                  { start: '09:00', end: '18:00' }, # Tuesday
                                                  { start: '09:00', end: '18:00' }, # Wednesday
                                                  { start: '09:00', end: '18:00' }, # Thursday
                                                  { start: '09:00', end: '18:00' }, # Friday
                                                  nil # Saturday
                                                ])
    end

    it "returns nil for days without business hours" do
      # Ensure Saturday and Sunday return nil when no business hours are set
      expect(merchant.business_hours_hsh[0]).to be_nil  # Sunday
      expect(merchant.business_hours_hsh[6]).to be_nil  # Saturday
    end

    it "correctly applies business hours for a range of days" do
      business_hours_hsh = merchant.business_hours_hsh
      expect(business_hours_hsh[1]).to eq({ start: '09:00', end: '18:00' })  # Monday
      expect(business_hours_hsh[5]).to eq({ start: '09:00', end: '18:00' })  # Friday
    end
  end

  describe ".business_hours_hsh" do
    let!(:business_hour_monday) do
      create(:business_hour, metadata: { day: 'mo', start_time: '09:00', end_time: '18:00' }, jsonable: merchant)
    end

    let!(:business_hour_tue) do
      create(:business_hour, metadata: { day: 'tu', start_time: '09:00', end_time: '18:00' }, jsonable: merchant)
    end

    let!(:business_hour_weekend) do
      create(:business_hour, metadata: { day: 'sa', start_time: '09:00', end_time: '14:00' }, jsonable: merchant)
    end

    it "returns a correct array for a single day" do
      expect(merchant.business_hours_hsh).to eq([
                                                  nil, # Sunday
                                                  { start: '09:00', end: '18:00' }, # Tuesday
                                                  { start: '09:00', end: '18:00' }, # Tuesday
                                                  nil,
                                                  nil,
                                                  nil,
                                                  { start: '09:00', end: '14:00' } # Saturday
                                                ])
    end

    it "returns nil for days without business hours" do
      # Ensure Saturday and Sunday return nil when no business hours are set
      expect(merchant.business_hours_hsh[0]).to be_nil  # Sunday
      expect(merchant.business_hours_hsh[3]).to be_nil  # Saturday
    end
  end
end
