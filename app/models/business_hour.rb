# app/models/lead.rb
class BusinessHour < JsonDocument
  include AccountOwnable
  string_enum :entry_type, %w[repair regular user blocker]
  string_enum :day, %w[mo_to_fr mo_to_sa mo_to_su mo tu we th fr sa su]

  store :metadata, accessors: %i[
    day start_time end_time
  ], coder: JSON

  class << self
    DAY_COVERAGE = {
      "mo_to_fr" => %w[mo tu we th fr],
      "mo_to_sa" => %w[mo tu we th fr sa],
      "mo_to_su" => %w[mo tu we th fr sa su],
      "mo" => %w[mo],
      "tu" => %w[tu],
      "we" => %w[we],
      "th" => %w[th],
      "fr" => %w[fr],
      "sa" => %w[sa],
      "su" => %w[su]
    }.freeze
    def generate_time_options
      options = {}
      time = Time.zone.parse("00:00")
      while time < Time.zone.parse("24:00")
        formatted_time = time.strftime("%H:%M")
        options[formatted_time] = formatted_time
        time += 15.minutes
      end
      options
    end

    def business_hours_hsh(merchant)
      business_hours_hsh = Array.new(7)
      day_index_mapping = { su: 0, mo: 1, tu: 2, we: 3, th: 4, fr: 5, sa: 6 }

      business_hours = merchant.business_hours

      business_hours.each do |business_hour|
        day_code = business_hour.metadata["day"]
        days_to_update = DAY_COVERAGE[day_code]

        days_to_update.each do |day|
          day_index = day_index_mapping[day.to_sym]
          business_hours_hsh[day_index] = {
            start: business_hour.metadata['start_time'],
            end: business_hour.metadata['end_time']
          }
        end
      end

      business_hours_hsh.freeze
    end

    def generate_day_options(merchant)
      # Step 1: Get day mappings from human-readable names to short codes
      day_mapping = ::BusinessHour.human_enum_names(:days).invert

      # Step 3: Initialize excluded_days array
      excluded_days = []

      # Step 4: Check if merchant is present and is a Merchant
      if merchant.present? && merchant.is_a?(Merchant)
        # Get existing days (individual days or ranges) from merchant's business hours
        existing_days = merchant.business_hours.filter_map { |bh| bh.metadata["day"] }

        # Expand both ranges and individual days to get full coverage
        excluded_days = existing_days.flat_map do |day|
          DAY_COVERAGE[day] || [day] # Expand the range (if it's a range) or handle single day
        end.uniq # Ensure uniqueness to avoid duplication of excluded days
      end

      # Step 5: Reject any remaining days that overlap with the excluded days
      day_mapping.reject do |_label, day_code|
        # If any part of the coverage of a range or single day is in excluded_days, remove it
        DAY_COVERAGE[day_code].intersect?(excluded_days)
      end

      # Step 6: Return the remaining days that are not covered by existing business hours
    end
  end
end
