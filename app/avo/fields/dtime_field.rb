class DtimeField < Avo::Fields::DateField
  attr_reader :all_day

  def initialize(name, **args, &)
    super(name, **args, &)
    add_boolean_prop args, :all_day
  end

  def start_id
    "#{id}_start"
  end

  def end_id
    "#{id}_end"
  end

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

  def start_date_formatted_value
    return if value.blank?

    value[:start_date]&.iso8601
  end

  def start_time_formatted_value
    return if value.blank?

    round_start_time
  end

  def end_date_formatted_value
    return if value.blank?

    value[:end_date]&.iso8601
  end

  def end_time_formatted_value
    return if value.blank?

    round_end_time
  end

  def round_start_time
    return if value.blank?

    round_to_nearest_15_minutes(value[:start_date]).strftime("%H:%M")
  end

  def round_end_time
    return if value.blank? || value[:end_date].blank?

    round_to_nearest_15_minutes(value[:end_date]).strftime("%H:%M")
  end

  def round_to_nearest_15_minutes(time)
    # Convert time to a number of minutes past the hour
    minutes = (time.min / 15.0).round * 15

    # Adjust the time to the rounded number of minutes
    if minutes == 60
      time.change(hour: time.hour + 1, min: 0)
    else
      time.change(min: minutes)
    end
  end

  def one_line_value
    return if value.blank?

    if value[:start_date].to_date == value[:end_date].to_date
      "#{I18n.l(value[:start_date], format: :short)} - #{I18n.l(value[:end_date], format: :time_only)}"
    else
      "#{I18n.l(value[:start_date], format: :short)} - #{I18n.l(value[:end_date], format: :short)} "
    end
  end
end
