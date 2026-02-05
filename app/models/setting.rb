class Setting < ApplicationRecord
  include AccountOwnable

  has_paper_trail(meta: { account_id: :id })
  MODEL_PREFIX = "set".freeze
  DEFAULT_BOOKING_SLOT_DURATION = 90 # in minutes
  DEFAULT_BOOKING_LEAD_TIME_MIN = 1 # in days
  DEFAULT_BOOKING_LEAD_TIME_MAX = 30 # in days
  DEFAULT_BOOKING_CONFIRMED_SLOTS_CAPACITY = 1
  DEFAULT_BOOKING_UNCONFIRMED_SLOTS_CAPACITY = 2

  has_many :customer_notification_rules, dependent: :destroy
  has_many :sequences, dependent: :destroy
  validate :validate_smtp_settings, if: -> { mail_external_smtp_enabled? }, on: :update

  store :metadata, accessors: %i[
    tax
    last_migration_sunchronized_at
    first_migration_sunchronized_at

    notification_settings
    document_footer
    print_detailed_issue_entries
    kva_print_template
    order_print_template
    repair_report_print_template
    invoice_print_template
    canceld_invoice_print_template
    mail_settings
    sms_settings
    booking_settings
  ], coder: JSON

  string_enum :category, %w[global application business booking]
  validates :category, presence: true

  validates :mail_authentication, :mail_domain, :mail_username, :mail_password,
            :default_mail_from, :mail_smtp_address, :mail_smtp_port, presence: true,
                                                                     if: -> { mail_external_smtp_enabled? }

  validates :sms_provider, presence: true, if: -> { sms_enabled? }
  validates :sms_username, :sms_password, presence: true, if: -> { sms_enabled? && sms_provider == 'sms77' }

  validates :booking_slot_duration, numericality: { greater_than: 0, less_than: 1440 }
  validates :booking_confirmed_slots_capacity,
            :booking_unconfirmed_slots_capacity,
            numericality: { greater_than: -1, less_than: 100 }

  validates :booking_lead_time_min, :booking_lead_time_max, numericality: { greater_than: -1, less_than: 365 }

  # notification_settings

  NOTIFICATION_TRIGGERS = %i[
    issue_kva_printed
    issue_order_printed
    issue_canceld_invoice_printed
    issue_awaiting_device
    issue_repairing
    issue_repairing_successfull
    issue_repairing_unsuccessfull
    issue_completed
  ].freeze

  SETTINGS = {
    notification_enabled: :notification_settings,
    mail_external_smtp_enabled: :mail_settings,
    mail_authentication: :mail_settings,
    mail_smtp_address: :mail_settings,
    mail_smtp_port: :mail_settings,
    mail_domain: :mail_settings,
    mail_username: :mail_settings,
    mail_password: :mail_settings,
    mail_enable_starttls_auto: :mail_settings,
    mail_openssl_verify_mode: :mail_settings,
    mail_ssl: :mail_settings,
    mail_tls: :mail_settings,
    default_mail_from: :mail_settings,
    default_mail_reply_to: :mail_settings,
    default_calendar_mail: :mail_settings,
    sms_enabled: :sms_settings,
    sms_provider: :sms_settings,
    sms_username: :sms_settings,
    sms_password: :sms_settings,
    booking_reminder_enabled: :booking_settings,
    booking_reminder_frequency: :booking_settings,
    booking_slot_search: :booking_settings,
    booking_confirmed_slots_capacity: :booking_settings,
    booking_unconfirmed_slots_capacity: :booking_settings,
    booking_lead_time_min: :booking_settings,
    booking_lead_time_max: :booking_settings,
    booking_enabled: :booking_settings,
    booking_slot_search_mode: :booking_settings,
    booking_slot_duration: :booking_settings

  }.freeze

  BOOLEAN_ATTRIBUTES = %i[
    mail_external_smtp_enabled notification_enabled sms_enabled
    print_detailed_issue_entries
    booking_enabled booking_reminder_enabled
  ].freeze

  SETTINGS.each do |method_name, store_key|
    define_method("#{method_name}=") do |value|
      assign_settings(store_key:, key: method_name, value:)
    end

    define_method(method_name) do
      send(store_key.to_s)&.dig(method_name)
    end
  end

  BOOLEAN_ATTRIBUTES.each do |method_name|
    define_method("#{method_name}?") do
      send(method_name).to_boolean
    end
  end

  # we override the default setter to ensure that the default value is set
  def booking_slot_duration
    booking_settings&.dig(:booking_slot_duration) || DEFAULT_BOOKING_SLOT_DURATION
  end

  def booking_lead_time_min
    booking_settings&.dig(:booking_lead_time_min) || DEFAULT_BOOKING_LEAD_TIME_MIN
  end

  def booking_lead_time_max
    booking_settings&.dig(:booking_lead_time_max) || DEFAULT_BOOKING_LEAD_TIME_MAX
  end

  def booking_confirmed_slots_capacity
    booking_settings&.dig(:booking_confirmed_slots_capacity) || DEFAULT_BOOKING_CONFIRMED_SLOTS_CAPACITY
  end

  def booking_unconfirmed_slots_capacity
    booking_settings&.dig(:booking_unconfirmed_slots_capacity) || DEFAULT_BOOKING_UNCONFIRMED_SLOTS_CAPACITY
  end

  # default ist true
  def booking_enabled
    if booking_settings&.dig(:booking_enabled).nil?
      true
    else
      booking_settings&.dig(:booking_enabled)
    end
  end

  def title
    I18n.t("activerecord.attributes.setting.#{category}")
  end

  private

  def assign_settings(store_key:, key:, value:)
    send("#{store_key}=", (send(store_key) || {}).merge(key => value))
  end

  def validate_smtp_settings
    smtp_settings = {
      address: mail_smtp_address,
      port: mail_smtp_port,
      domain: mail_domain,
      user_name: mail_username,
      password: mail_password,
      authentication: mail_authentication.to_sym
    }

    begin
      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
      smtp.enable_starttls_auto
      smtp.start(
        smtp_settings[:domain],
        smtp_settings[:user_name],
        smtp_settings[:password],
        smtp_settings[:authentication]
      ) do |conn|
        conn.helo(smtp_settings[:domain])
      end
    rescue StandardError => e
      errors.add(:base, "SMTP settings are invalid: #{e.message}")
    end
  end
end
