class RepairSet < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "set".freeze

  belongs_to :device_failure_category
  belongs_to :device_model
  has_one :device_manufacturer, through: :device_model
  belongs_to :device_color, optional: true
  has_many   :repair_set_entries, dependent: :destroy
  has_many   :articles, through: :repair_set_entries

  validates :name, presence: true
  before_validation :generate_name_before_validation, on: :create

  attribute :autogenerate_name, :boolean, default: false
  attribute :via_cloned_id, :integer

  alias_attribute :price, :retail_price
  alias :summary_entries :repair_set_entries

  delegate :stock_status, to: :stock_service

  attribute :skip_broadcasting, default: false
  after_commit :broadcast_changes, unless: -> { skip_broadcasting }

  # after_commit do
  #   # broadcast_invoke_later "window.location.reload", args: ["Repairset was saved! #{to_gid.to_s}"]
  #   # broadcast_invoke "console.log", args: ["Repairset was saved! #{to_gid.to_s}"]
  #   broadcast_invoke_later("reload", args: [""], selector: "#has_many_field_show_repair_set_entries")
  #   # broadcast_invoke_later "document.getElementById('has_many_field_show_repair_set_entries').reload",
  #   # args: ["Repairset was saved! #{to_gid.to_s}"]
  #   # broadcast_invoke "reload", selector: "#has_many_field_show_repair_set_entries",args:
  #   # ["Repairset was saved! #{to_gid.to_s}"]
  #   # .invoke("setAttribute", args: ["data-turbo-ready", true], selector: ".button") # selector

  #   # broadcast with a background job
  #   # broadcast_invoke_later "console.log", args: ["Post was saved! #{to_gid.to_s}"]
  # end

  def name_with_price_and_stock_status
    status = I18n.t("activerecord.attributes.repair_set.stock_statuses.#{stock_status}")
    "#{name} [#{price.to_brutto_currency}] [#{status}]"
  end

  def broadcast_changes
    # broadcast_invoke_later("reload", args: [""], selector: "#has_many_field_show_repair_set_entries")
  end

  def update_set_price
    return unless repair_set_entries.any?

    update(retail_price: beautified_retail_price)
  end

  def raw_retail_price
    repair_set_entries.sum(&:total_price)
  end

  def template_attributes
    {
      device_model: device_model.name,
      device_color: device_color&.name,
      device_manufacturer: device_manufacturer.name,
      device_failure_category: device_failure_category.name,
      name:,
      retail_price:
    }
  end

  private

  def beautified_retail_price
    # Beautification disabled - return raw price directly
    # tax_factor = (AppConfig::GLOBAL_TAX / 100.0) + 1
    # b = Prices::Beautifier.call(original_price: raw_retail_price * tax_factor).success
    # b / tax_factor
    raw_retail_price
  end

  def generate_name_before_validation
    return unless autogenerate_name

    return if name.present?
    return if device_model.blank? || device_failure_category.blank?

    self.name = ["#{device_failure_category.name} Reparatur", device_model&.name, device_color&.name].join(" ")
  end

  def stock_service
    @stock_service ||= StockService::Status.stock_service(self)
  end

  class << self
    def find_sets_for_issue(issue:)
      query = RepairSet.where(account: issue.account)
      if issue.device.present?
        query = query.where(device_model: issue.device.device_model)
        # query = query.where(device_color: [nil, issue.device.device_color]) if issue.device.device_color.present?
      end
      if issue.input_device_failure_categories.present?
        query = query.where(device_failure_category_id: DeviceFailureCategory.by_account.where(
          name: issue.input_device_failure_categories
        ))
      end
      query
    end

    # https://myrecloud.atlassian.net/browse/REC-62
    def __find_sets_for_issue(issue:)
      query = RepairSet.where(account: issue.account)
      if issue.device.present?
        query = query.where(device_model: issue.device.device_model)
        query = query.where(device_color: [nil, issue.device.device_color]) if issue.device.device_color.present?
      end
      if issue.input_device_failure_categories.present?
        query = query.where(device_failure_category_id: DeviceFailureCategory.by_account.where(
          name: issue.input_device_failure_categories
        ))
      end
      query
    end
  end
end
