class Template < ApplicationRecord
  include AccountOwnable

  store :metadata, accessors: %i[
    tags
  ], coder: JSON

  string_enum :template_type, %w[mail print text sms repair_report]
  has_many :customer_notification_rules, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: [:account_id], case_sensitive: false }
  validates :body, presence: true
  validates :subject, presence: true, if: -> { template_type_mail? }

  attribute :html_body, :string
  attribute :text_body, :string

  before_destroy :check_if_still_in_use

  def customer_notification_rule_triggers
    customer_notification_rules.flat_map(&:trigger_events)
  end

  def duplicate!
    record = dup
    record.name += " cloned"
    record.save!
    record
  end

  def html_body=(value)
    return unless %w[mail repair_report print repair_report].include?(template_type)

    self.body = value
  end

  def html_body
    body
  end

  def text_body=(value)
    return unless %w[text sms].include?(template_type)

    self.body = value
  end

  def text_body
    body
  end

  def tags=(value)
    super(Array(value).compact_blank.uniq)
  end

  def preview_content
    issue = fetch_random_issue
    data = prepare_data(issue)
    parse_result = parse_template(data)

    raise "Could not run parse call for template: #{name}" unless parse_result.success?

    result_body(parse_result)
  end

  def prepare_data(entry)
    case entry
    when CalendarEntry
      prepare_data_for_calendar_entry(entry)
    when Issue
      prepare_data_for_issue(entry)
    else
      raise "Unsupported entry type: #{entry.class}"
    end
  end

  private

  def prepare_data_for_calendar_entry(calendar_entry)
    customer = calendar_entry.customer
    merchant = calendar_entry.merchant
    unless customer
      customer = calendar_entry.calendarable&.customer if calendar_entry.calendarable_type == 'Issue'
      customer ||= Customer.new
    end

    {
      customer: customer.template_attributes,
      calendar_entry: calendar_entry.template_attributes,
      service_name: service_name(calendar_entry),
      service_location: calendar_entry.merchant.primary_address.one_liner,
      merchant: merchant&.template_attributes
    }
  end

  def service_name(calendar_entry)
    return calendar_entry.selected_repair_set.name if calendar_entry.selected_repair_set.present?

    str = I18n.t(calendar_entry.entry_type, scope: 'activerecord.attributes.calendar_entry.entry_types')

    if calendar_entry.calendarable_type == 'Issue'
      device_name = calendar_entry.calendarable.device&.name
      str += " für #{device_name}" if device_name.present?
    end

    str
  end

  def prepare_data_for_issue(issue)
    customer = issue.customer || Customer.new
    merchant = issue.merchant || Merchant.new

    {
      customer: customer.template_attributes,
      merchant: merchant.template_attributes,
      issue: issue.template_attributes,
      device: (issue.device&.template_attributes || Device.new.template_attributes)
    }
  end

  # This method will halt the destroy action if protected is true
  def check_if_still_in_use
    in_use = print_templare_in_use || email_template_in_use

    return unless in_use

    errors.add(:base, I18n.t('shared.messages.destroy_not_possible'))
    errors.add(:base, :still_in_use, key: in_use)
    raise ActiveRecord::RecordInvalid, self
  end

  def print_templare_in_use
    keys = %i[
      kva_print_template
      order_print_template
      repair_report_print_template
      invoice_print_template
      canceld_invoice_print_template
    ]

    keys.find do |key|
      account.application_settings.send(key) == id.to_s
    end
  end

  def email_template_in_use
    notification = account.application_settings.customer_notification_rules.where(template: self).first
    notification&.trigger_events&.map do |event|
      I18n.t(event, scope: "activerecord.attributes.customer_notification_rule.trigger_events")
    end&.join(", ")
  end

  def fetch_random_issue
    Issue.by_account.random || Issue.new
  end

  def parse_template(data)
    ::Templates::ParseOperation.call(template: self, data:)
  end

  def result_body(parse_result)
    faraday_result = parse_result.success
    raise "Could not parse call for template: #{name}" unless faraday_result.success?

    faraday_result.body["body"]
  end
end
