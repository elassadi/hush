class CalendarEntry < ApplicationRecord
  include AccountOwnable
  include MerchantOwnable
  include UserOwnable
  string_enum :status, %w[open in_progress done canceld], _default: :open
  string_enum :entry_type,
              %w[repair regular user blocker]
  string_enum :category, %w[pause holiday vacation sickness lunch private_appointment other]

  belongs_to :calendarable, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :customer, optional: true
  belongs_to :merchant
  belongs_to :selected_repair_set, optional: true, class_name: "RepairSet"

  validates :entry_type, :start_at, presence: true
  validates :category, presence: true, allow_blank: false, if: -> { entry_type.in?(%w[user blocker]) }
  validates :notes, presence: true, allow_blank: false, if: lambda {
    entry_type.in?(%w[user blocker]) && category == "other"
  }
  has_many :documents, as: :documentable, inverse_of: :documentable, dependent: :destroy

  validates :start_at, presence: true
  validates :end_at, presence: true, if: -> { all_day == false }
  validates :start_at, comparison: { less_than: :end_at }, if: -> { all_day == false }

  before_validation :assign_event_color

  after_commit :broadcast_refresh

  attribute :notify_customer, :boolean
  attribute :confirm_and_notify_customer, :boolean

  scope :confirmed, lambda {
    not_status_canceld.where("JSON_EXTRACT(JSON_UNQUOTE(metadata), '$.confirmed_at') IS NOT NULL")
  }

  scope :unconfirmed, lambda {
    where("JSON_EXTRACT(JSON_UNQUOTE(metadata), '$.confirmed_at') IS NULL")
  }

  store :metadata, accessors: %i[
    source notes confirmed_at event_color category selected_repair_set_id
    repair_set_id
    reminded_per_sms_at reminded_per_email_at
  ], coder: JSON

  def broadcast_refresh
    target = ["MainCalender", "-", Current.user.account.uuid].join
    broadcast_invoke_later_to(target, "window.mainCalendarController.refreshCalendar")
  end

  def selected_repair_set
    RepairSet.find_by(id: selected_repair_set_id, account:)
  end

  def template_attributes
    {
      calendar_entry_id: id,
      start_at: I18n.l(start_at),
      canceld: status_canceld?,
      just_confirmed: confirmed? && confirmed_at > updated_at - 5.minutes,
      confirmed: confirmed?,
      booking_url: "https://www.hush-haarentfernung.de/appointment"
    }
  end

  def event
    {
      start_date: start_at,
      end_date: end_at
    }
  end

  def as_json(_options = {})
    data = {
      id:,
      start: start_at.iso8601,
      end: end_at&.iso8601,
      allDay: all_day || end_at.blank?,
      calendarable_type:,
      calendarable_id:,
      classNames: ["calendar-entry"],
      textColor: default_text_color,
      extendedProps: {
        id:,
        entry_type:,
        notes:,
        status:,
        confirmed:,
        name: name_of_calendarable,
        default_notes:
      }
    }
    data[:color] = event_color if event_color.present?
    data
  end

  def default_notes
    case entry_type
    when 'repair', 'regular'
      default_notes_for_issue
    when 'user'
      default_notes_for_user
    when 'blocker'
      default_notes_for_blocker
    end
  end

  def default_notes_for_issue
    return unless entry_type.in?(%w[repair regular])

    issue = calendarable
    status_badge = badge_html(IssueResource::STATUS_OPTIONS, "top", status: issue.status)
    stock_badge = badge_html(IssueEntryResource::STOCK_OPTIONS, "right", status: issue.stock_status, stock: true)

    %{<b>REP-#{issue_sequence_id}</b> / #{issue.device&.name}<br>#{status_badge} #{stock_badge}}
  end

  # def __default_notes_for_issue
  #   return unless entry_type.in? %w[repair regular]

  #   issue = calendarable
  #   level = IssueResource::STATUS_OPTIONS.find { |_k, v| v.include?(issue.status) }&.first || "gray"
  #   bg = Constants::STATUS_BADGE_BACKGROUND[level.to_sym]
  #   text_color = Constants::STATUS_BADGE_TEXT_COLOR[level.to_sym]
  #   stock_status = issue.stock_status

  #   level = IssueEntryResource::STOCK_OPTIONS.find { |_k, v| v.include?(stock_status) }&.first || "gray"
  #   stock_status_bg = Constants::STATUS_BADGE_BACKGROUND[level.to_sym]
  #   stock_text_color = Constants::STATUS_BADGE_TEXT_COLOR[level.to_sym]

  #   %{
  #     <b>REP-#{issue_sequence_id}</b> / #{issue.device&.name}<br>
  #     <div style="padding: 2px" class='calendar-badge #{issue.status}  whitespace-nowrap  text-xs
  #     uppercase font-semibold inline-flex items-center rounded #{bg} #{text_color}'
  #     data-tippy-theme="calendar"
  #     data-tippy-arrow="false"
  #     data-tippy-placement="top"
  #     data-tippy="tooltip"
  #     title="#{translated_issue_state(issue.status, short: false)}"
  #     >
  #     #{translated_issue_state(issue.status)}</div>
  #     <div style="padding: 2px" class='calendar-badge #{stock_status}  whitespace-nowrap  text-xs
  #     uppercase font-semibold inline-flex items-center rounded #{stock_status_bg} #{stock_text_color}'
  #     data-tippy-theme="calendar"
  #     data-tippy-arrow="false"
  #     data-tippy-placement="right"
  #     data-tippy="tooltip"
  #     title="#{translated_issue_stock_status(stock_status, short: false)}"
  #     >
  #     #{translated_issue_stock_status(stock_status)}</div>
  #   }
  # end

  def default_text_color
    return "#3E4A54" unless entry_type.in?(%w[user blocker])

    "#ffffff"
  end

  def default_notes_for_user
    return unless entry_type.in? %w[user]

    I18n.t(category, scope: %i[activerecord attributes calendar_entry default_notes_for_user])
  end

  def default_notes_for_blocker
    return unless entry_type.in? %w[blocker]

    I18n.t(category, scope: %i[activerecord attributes calendar_entry default_notes_for_blocker])
  end

  def issue_sequence_id
    return unless entry_type.in? %w[repair regular]

    calendarable.sequence_id
  end

  def name_of_calendarable
    case entry_type
    when 'repair', 'regular'
      calendarable.customer.name
    when 'user', 'customer'
      calendarable.name
    end
  end

  def confirmed
    confirmed_at.present?
  end

  alias confirmed? confirmed

  def confirmed=(value)
    self.confirmed_at = value.to_boolean ? Time.zone.now : nil
  end

  def assign_confirmed_at
    return if confirmed

    self.confirmed_at = Time.zone.now if entry_type.in?(%w[user])
  end

  def assign_event_color
    return unless entry_type.in?(%w[user blocker])

    self.event_color = "#848181" # gray
  end

  def can_be_canceld?
    return false if entry_type.in?(%w[user blocker])
    return false if status_canceld?

    true
  end

  def can_be_confirmed?
    return false if entry_type.in?(%w[user blocker]) || confirmed?
    return false unless status_open?

    true
  end

  def create_ics_document
    document = Document.new(account_id:, documentable: self, status: :active)
    document.send(:generate_uuid)
    document.key = document.uuid

    content = StringIO.new(render_ics_file_content)
    document.file.attach(io: content, filename: "termin.ics")

    return document if document.save

    nil
  end

  def source_api?
    source == "api"
  end

  private

  def badge_html(options, placement, status: nil, stock: false)
    level = options.find { |_k, v| v.include?(status) }&.first || "gray"
    bg = Constants::STATUS_BADGE_BACKGROUND[level.to_sym]
    text_color = Constants::STATUS_BADGE_TEXT_COLOR[level.to_sym]

    if stock
      short_translation = translated_issue_stock_status(status, short: false)
      translation = translated_issue_stock_status(status)
    else
      short_translation = translated_issue_state(status, short: false)
      translation = translated_issue_state(status)
    end

    %{
      <div style="padding: 2px" class='calendar-badge #{status} whitespace-nowrap text-xs
      uppercase font-semibold inline-flex items-center rounded #{bg} #{text_color}'
      data-tippy-theme="calendar"
      data-tippy-arrow="false"
      data-tippy-placement="#{placement}"
      data-tippy="tooltip"
      title="#{short_translation}"
      >
      #{translation}
      </div>
    }
  end

  # def render_ics_file_content
  #   Icalendar::Calendar.new.tap do |calendar|
  #     calendar.cancel if status_canceld?
  #     calendar.event do |event|
  #       event.uid = uuid
  #       event.sequence = updated_at.to_i
  #       event.dtstart = start_at
  #       event.dtend = end_at
  #       event.summary = "#{account.merchant.company_name} / Behandlungstermin"
  #       event.description = "Behandlungstermin "
  #       event.organizer = "mailto:#{account.merchant.email}"
  #       event.location = account.merchant.primary_address.one_liner
  #       event.status = ics_status
  #     end
  #   end.to_ical
  # end

  def render_ics_file_content
    Icalendar::Calendar.new.tap do |calendar|
      calendar.cancel if status_canceld?
      calendar.event { |event| configure_event(event) }
    end.to_ical
  end

  def configure_event(event)
    event.uid = uuid
    event.sequence = updated_at.to_i
    event.dtstart = start_at
    event.dtend = end_at
    event.summary = event_summary
    event.description = "Behandlungstermin"
    event.organizer = "mailto:#{account.merchant.email}"
    event.location = account.merchant.primary_address.one_liner
    event.status = ics_status
  end

  def event_summary
    "#{account.merchant.company_name} / Behandlungstermin"
  end

  def ics_status
    return "CANCELLED" if status_canceld?
    return "CONFIRMED" if confirmed?

    "TENTATIVE"
  end

  def translated_issue_state(status, short: true)
    Issues::IssueWorkflow.human_workflow_status(status, short:)
  end

  def translated_issue_stock_status(stock_status, short: true)
    return I18n.t(stock_status, scope: %i[activerecord attributes supplier_source stock_statuses short]) if short

    I18n.t(stock_status, scope: %i[activerecord attributes supplier_source stock_statuses])
  end
end
