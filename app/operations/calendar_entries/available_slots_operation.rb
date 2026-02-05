module CalendarEntries
  class AvailableSlotsOperation < BaseOperation
    attributes :start_date, :end_date, :slot_duration, :merchant_id
    optional_attributes :days_only, :use_standard_slot_search
    DEFAULT_SLOT_SEARCH_STEP = 15 # minutes
    DEFAULT_BOOKING_SLOT_DURATION = 30 # minutes

    MAX_APPOINTMENT_PER_SLOT = {
      confirmed: 1,
      unconfirmed: 2
    }.freeze

    def call
      result = days_only ? find_available_days : find_slots
      return Success(result.success) if result.success?

      Failure(result.failure)
    end

    private

    def booking_settings
      @booking_settings ||= Current.account.booking_settings
    end

    # def current_date
    #   Date.current
    # end

    def booking_slot_duration
      @booking_slot_duration ||= booking_settings.booking_slot_duration.to_i || DEFAULT_BOOKING_SLOT_DURATION
    end

    def max_appointment_per_slot_setting
      @max_appointment_per_slot_setting ||= {
        confirmed: booking_settings.booking_confirmed_slots_capacity.to_i || MAX_APPOINTMENT_PER_SLOT[:confirmed],
        unconfirmed: booking_settings.booking_unconfirmed_slots_capacity.to_i || MAX_APPOINTMENT_PER_SLOT[:unconfirmed]
      }
    end

    def find_available_days
      dates = (start_date..end_date).select do |date|
        slots_for_date = find_slots_for_date(date)
        slots_for_date.any?
      end
      # Return date strings in YYYY-MM-DD format for frontend compatibility
      date_strings = dates.map { |date| date.strftime('%Y-%m-%d') }
      Success(date_strings)
    end

    def find_slots
      slots = (start_date..end_date).map do |date|
        find_slots_for_date(date)
      end.flatten
      Success(slots)
    end

    def find_slots_for_date(date)
      business_hours = business_hours_hsh[date.wday]
      return [] unless business_hours

      null_hour_start = to_time_in_zone(date:, hour: 0, min: 0)

      start_hour, start_min = business_hours[:start].split(':').map(&:to_i)
      end_hour, end_min = business_hours[:end].split(':').map(&:to_i)

      business_start_time = to_time_in_zone(date:, hour: start_hour, min: start_min)
      business_end_time = to_time_in_zone(date:, hour: end_hour, min: end_min)

      calendar_entries = fetch_calendar_entries(null_hour_start:, business_end_time:)

      root_node = IntervalTree::Builder.build_tree(calendar_entries)

      mode = booking_settings.booking_slot_search_mode.presence || 'standard'

      if use_standard_slot_search || mode == 'standard'
        standard_slot_search(
          business_start_time:, business_end_time:,
          root_node:
        )
      else
        optimized_slot_search(business_start_time:, business_end_time:, root_node:)
      end
    end

    def standard_slot_search(business_start_time:, business_end_time:, root_node:)
      last_possible_start = business_end_time - slot_duration
      (business_start_time.to_i..last_possible_start.to_i).step(DEFAULT_SLOT_SEARCH_STEP.minutes).filter_map do |t|
        start_time = Time.zone.at(t)
        end_time = start_time + slot_duration
        next unless within_overlap_limit?(root_node, start_time, end_time)

        return { start: start_time, end: end_time } if days_only

        { start: start_time, end: end_time }
      end
    end

    def within_overlap_limit?(root_node, start_time, end_time)
      intersection = IntervalTree::Search.overlaps(root_node, start_time, end_time)
      return true if intersection.blank?

      confirmed = intersection.count do |node|
        node.node_data.confirmed_at.present?
      end

      blocker = intersection.count do |node|
        node.node_data.entry_type_blocker?
      end

      unconfirmed = intersection.count - confirmed
      max_settings = max_appointment_per_slot_setting

      confirmed_ok = max_settings[:confirmed].zero? || confirmed < max_settings[:confirmed]
      unconfirmed_ok = max_settings[:unconfirmed].zero? || unconfirmed < max_settings[:unconfirmed]

      blocker.zero? && confirmed_ok && unconfirmed_ok
    end

    def optimized_slot_search(business_start_time:, root_node:, business_end_time:)
      last_possible_start = business_end_time - slot_duration
      available_slots = []
      current_time = business_start_time.to_i

      while current_time <= last_possible_start.to_i
        start_time = Time.zone.at(current_time)
        end_time = start_time + slot_duration

        within_limits = within_overlap_limit?(root_node, start_time, end_time)

        if within_limits
          available_slots << { start: start_time, end: end_time }
          # After finding an empty slot, step forward by xx minutes
          current_time += booking_slot_duration.minutes
        else
          current_time += DEFAULT_SLOT_SEARCH_STEP.minutes
        end

      end

      available_slots
    end

    def business_hours_hsh
      @business_hours_hsh ||= merchant.business_hours_hsh
    end

    def fetch_calendar_entries(null_hour_start:, business_end_time:)
      CalendarEntry
        .by_account
        .not_entry_type_user
        .not_status_canceld
        .where(merchant_id:)
        .where(
          "(start_at BETWEEN :null_hour_start AND :business_end_time) OR " \
          "(all_day = true AND start_at < :null_hour_start AND end_at >= :null_hour_start)",
          null_hour_start:,
          business_end_time:
        )
        .order(:start_at)
    end

    def fetch_confirmed_entries(null_hour_start:, business_end_time:)
      CalendarEntry
        .by_account
        .confirmed
        .not_entry_type_user
        .not_status_canceld
        .where(merchant_id:)
        .where(start_at: null_hour_start..business_end_time)
        .order(:start_at)
    end

    def merchant
      @merchant ||= Merchant.by_account.find(merchant_id)
    end

    def to_time_in_zone(date:, hour:, min:)
      # Convert date to Date object if it's a string
      date = date.to_date if date.is_a?(String)

      # Use Time.zone.local to create a time in the configured Rails time zone
      Time.zone.local(date.year, date.month, date.day, hour, min)
    end
  end
end
