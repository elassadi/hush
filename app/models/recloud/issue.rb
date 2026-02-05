class Issue < ApplicationRecord
  MODEL_PREFIX = "rep".freeze
  include AccountOwnable
  include UserOwnable
  include MerchantOwnable
  include Lockable

  AVAILABLE_ACTIONS = %i[
    activate
    print_kva
    print_invoice
  ].freeze

  store :metadata, accessors: %i[
    input_device_failure_categories device_accessories_list
    watcher_list device_received_at device_repaired_at repair_report_id
    request_approval_at imported_ref_id
    has_insurance_case insurance_id insurance_number insurance_claim_number
    source
  ], coder: JSON
  string_enum :status_category, %w[open in_progress done], _default: :open

  attribute :device_received, :boolean, default: false
  attribute :device_repaired, :boolean, default: false
  attribute :imported_ref_id
  attribute :via_cloned_id, :integer
  attribute :unlock_pattern, :string # dummy attrobute only for resources page
  attribute :unlock_pin, :string # dummy attrobute only for resources page
  attribute :private_comment, :string

  attribute :hidden_selected_repair_set_id, :string # dummy attrobute only for resources page
  attribute :status, :string, default: 'draft'
  attribute :selected_repair_set_id, :integer
  attribute :possible_repair_sets

  has_paper_trail(versions: { class_name: "PaperTrail::IssueVersion" }, meta: { account_id: :account_id })
  belongs_to :device, optional: true, dependent: :destroy
  belongs_to :customer
  belongs_to :insurance, optional: true

  alias_attribute :author, :owner
  alias_attribute :author_id, :owner_id

  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :selected_repair_set, optional: true, class_name: "RepairSet"

  has_many :comments, as: :commentable, dependent: :delete_all
  has_many :issue_entries, lambda { |record|
                             where(account_id: record.account_id)
                           }, dependent: :destroy
  has_many :issue_entries_with_articles, -> { not_category_rabatt }, class_name: 'IssueEntry'

  has_many :calendar_entries, as: :calendarable, dependent: :delete_all
  has_many :documents, as: :documentable, inverse_of: :documentable, dependent: :destroy
  has_many :invoices, as: :documentable, inverse_of: :documentable, class_name: "InvoiceDocument"
  has_one :invoice, -> { where(type: "InvoiceDocument", status: "active").order(created_at: :desc) },
          as: :documentable, inverse_of: :documentable, class_name: "InvoiceDocument"
  has_many :repair_report_documents, as: :documentable, inverse_of: :documentable, class_name: "RepairReportDocument"
  has_one :repair_report_document, lambda {
                                     where(type: "RepairReportDocument", status: "active").order(created_at: :desc)
                                   },
          as: :documentable, inverse_of: :documentable, class_name: "RepairReportDocument"
  has_many :activities, -> { order(created_at: :desc) }, as: :activityable, dependent: :delete_all

  validates :insurance_number, presence: true, if: :has_insurance_case?

  delegate :run_event!, :can_run_event?, to: :workflow
  delegate :imei, to: :device, allow_nil: true
  delegate :stock_status, to: :stock_service

  %i[ draft awaiting_approval awaiting_parts ready_to_repair awaiting_device
      repair_in_progress repair_done repaired unrepaired canceld].each do |state|
    define_method "status_#{state}?" do
      status == state.to_s
    end
  end

  def recent_customer_comment_by_mail
    comments.notify_customer_with_mail.last
  end

  def recent_customer_comment_by_sms
    comments.notify_customer_with_sms.last
  end

  def scheduled_repair_at
    most_recent_calendar_entry&.start_at
  end

  def most_recent_calendar_entry
    calendar_entries.not_status_canceld.confirmed.first
  end

  def has_insurance_case? # rubocop:todo Naming/PredicateName
    has_insurance_case.to_boolean
  end

  def has_insurance_case=(value)
    metadata["has_insurance_case"] = value
  end

  def insurance_id=(value)
    metadata["insurance_id"] = value
  end

  def insurance
    Insurance.where(id: metadata["insurance_id"]).first
  end

  alias :summary_entries :issue_entries

  def title
    icon = locked? ? " 🔒" : ""
    "#{MODEL_PREFIX}-#{sequence_id}#{icon}".upcase
  end

  def watcher_ids
    (Array(watcher_list) + [author_id, assignee_id]).flatten.compact
  end

  def watchers
    User.includes(%i[account role]).where(id: watcher_ids)
  end

  def price
    @price ||= begin
      sum = issue_entries.not_category_rabatt.pick(
        Arel.sql(" sum(price * qty) as total ")
      ).to_f
      rabatt ? sum - rabatt : sum
    end
  end

  def rabatt_entry
    return unless issue_entries.category_rabatt.exists?

    issue_entries.category_rabatt.first
  end

  def rabatt
    @rabatt ||= rabatt_entry&.price
  end

  def has_rabatt? # rubocop:todo Naming/PredicateName
    rabatt_entry.present? && rabatt > 0
  end

  def workflow
    @workflow ||= Issues::B2cWorkflow.create(self)
  end

  def can_be?(event)
    result = super
    return true if result

    workflow.can_run_event?(event)
  end

  def can_be_locked?
    !locked?
  end

  def can_be_unlocked?
    locked?
  end

  def can_be_invoiced?
    return false if last_invoiced_at.present? && (
      last_invoice_canceld_at.blank? || last_invoice_canceld_at < last_invoiced_at
    )

    can_be?(:print_invoice)
  end

  def can_be_cancel_invoiced?
    return false if last_invoiced_at.blank?
    return false if last_invoice_canceld_at.present? && last_invoice_canceld_at > last_invoiced_at

    can_be?(:print_canceld_invoice)
  end

  def device_received
    device_received_at.present?
  end
  alias_method :device_received?, :device_received

  def device_received=(value)
    self.device_received_at = value.to_boolean.blank? ? nil : Time.zone.now
  end

  def request_approved
    request_approval_at.present?
  end
  alias_method :request_approved?, :request_approved

  def request_approved=(value)
    self.request_approval_at = value.to_boolean.present? ? Time.zone.now : nil
  end

  def device_repaired
    device_repaired_at.present?
  end

  def device_repaired=(value)
    self.device_repaired_at = value.to_boolean.present? ? Time.zone.now : nil
  end

  def unlock_pattern
    device&.unlock_pattern
  end

  def unlock_pin
    device&.unlock_pin
  end

  def ready_to_repair?
    # issue_entries.includes(%i[article stock_reservation]).all? do |entry|
    #   return false unless entry.stock_is_available?
    # end
    not_available = issue_entries.includes(%i[article stock_reservation]).any? do |entry|
      !entry.stock_is_available?
    end

    not_available ? false : true
  end

  def repair_report
    return unless repair_report_id

    comments.find_by(id: repair_report_id)
  end

  def repair_report_content
    repair_report&.body
  end

  # rubocop:todo Metrics/AbcSize
  def template_attributes # rubocop:todo Metrics/CyclomaticComplexity, Metrics/AbcSize
    {
      id:,
      uuid:,
      sequence_id:,
      created_at:,
      owner_name: owner&.name,
      has_rabatt: has_rabatt?,
      total_with_rabatt: price,
      rabatt:,
      tax: account.global_settings.tax.presence || AppConfig::GLOBAL_TAX,
      customer: customer&.template_attributes,
      issue_entries: template_issue_entries,
      device: device&.name,
      device_received:,
      device_repaired:,
      request_approved:,
      repair_report_content:,
      scheduled_repair_at:,
      has_insurance_case: has_insurance_case?,
      email_comment: recent_customer_comment_by_mail&.body,
      sms_comment: recent_customer_comment_by_sms&.body
    }.tap do |attributes|
      attributes[:insurance] = insurance_attributes if has_insurance_case?
    end
  end
  # rubocop:enable Metrics/AbcSize

  def template_issue_entries
    return detailed_template_issue_entries if account.global_settings.print_detailed_issue_entries?

    grouped_template_issue_entries
  end

  def detailed_template_issue_entries
    issue_entries.not_category_rabatt.map(&:template_attributes)
  end

  def grouped_template_issue_entries
    unique_entries = fetch_unique_issue_entries

    combined_entries = fetch_repair_set_entries_data + unique_entries
    assign_positions_to_entries(combined_entries)
  end

  def fetch_unique_issue_entries
    issue_entries
      .not_category_rabatt
      .not_category_repair_set
      .where(repair_set_entry_id: nil)
      .map(&:template_attributes)
  end

  def assign_positions_to_entries(entries)
    entries.map.with_index(1) do |entry, index|
      entry.merge(pos: index)
    end
  end

  def convert_to_html_entities(html_string)
    replacements = {
      'ä' => '&auml;',
      'Ä' => '&Auml;',
      'ö' => '&ouml;',
      'Ö' => '&Ouml;',
      'ü' => '&uuml;',
      'Ü' => '&Uuml;',
      'ß' => '&szlig;',
      'é' => '&eacute;',
      'á' => '&aacute;',
      'ó' => '&oacute;',
      'í' => '&iacute;',
      'ú' => '&uacute;',
      'ñ' => '&ntilde;',
      'Ñ' => '&Ntilde;'
    }

    replacements.each do |char, entity|
      html_string.gsub!(char, entity)
    end

    html_string
  end

  def generate_uuid
    loop do
      self.uuid = "rep_#{(Issue.maximum(:id) || 0) + 1}"
      break unless self.class.exists?(uuid:)
    end
  end

  def repair_set_entries(repair_set_id = nil)
    query = issue_entries
            .joins(:repair_set_entry)
            .category_repair_set
            .where.not(repair_set_entry_id: nil)

    return query if repair_set_id.blank?

    query.joins(:repair_set).where(repair_sets: { id: repair_set_id })
  end

  def repair_set_ids
    sets_count = repair_set_entries.group("repair_set_entries.repair_set_id").count
    return sets_count.keys if sets_count

    []
  end

  def repair_sets
    RepairSet.where(id: repair_set_ids.keys)
  end

  def source_api?
    source == "api"
  end

  private

  def fetch_repair_set_entries_data
    sets = Hash.new { |hash, key| hash[key] = [] }
    repair_set_entries.find_each do |entry|
      sets[entry.repair_set.id] << entry
    end

    sets.map do |repair_set_id, entries|
      {
        id: repair_set_id,
        pos: -1,
        name: "#{entries.first.repair_set.name} [S]",
        total: entries.sum(&:total),
        price: entries.sum(&:total),
        qty: 1
      }
    end
  end

  def insurance_attributes
    return { number: insurance_number } unless insurance

    {
      name: insurance.name,
      number: insurance_number,
      company_name: insurance.company_name,
      address: {
        street_address: insurance.primary_address&.street_address,
        post_code: insurance.primary_address&.post_code,
        city: insurance.primary_address&.city
      }
    }
  end

  def stock_service
    @stock_service ||= StockService::Status.stock_service(self)
  end
end
