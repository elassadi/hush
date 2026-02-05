class Device < ApplicationRecord
  include AccountOwnable

  MODEL_PREFIX = "dev".freeze
  #  IMEI_LENGTH = Rails.env.development? ? 11 : 15
  IMEI_LENGTH = 15
  SERIAL_NUMBER_MAX_LENGTH = 30
  belongs_to :device_model
  has_one :device_manufacturer, through: :device_model
  belongs_to :device_color
  has_many :issues
  has_many :customers, -> { distinct }, through: :issues
  has_many :repair_sets, through: :device_model

  scope :with_no_issues, -> { Device.where.missing(:issues) }
  scope :with_no_issues_for_customer, lambda { |customer_id|
    Device.left_joins(:issues).where("issues.id IS NULL OR issues.customer_id = ?", customer_id)
  }

  delegate :gsm_path, to: :device_model
  delegate :image, to: :device_model
  validates :imei, length: { is: IMEI_LENGTH }, allow_blank: true
  # validates :imei, uniqueness: { scope: [:account_id] }, allow_blank: true
  validates :serial_number, length: { maximum: SERIAL_NUMBER_MAX_LENGTH }
  validates :serial_number, presence: true, if: -> { imei.blank? }
  store :metadata, accessors: %i[unlock_pattern unlock_pin], coder: JSON

  before_destroy :prevent_destroy

  attribute :virtual_data

  def virtual_data
    [
      {
        id: 1,
        name: "Virtual Data 1",
        status: "active"
      },
      {
        id: 2,
        name: "Virtual Data 2",
        status: "active"
      }
    ]
  end

  def name
    [device_manufacturer&.name, device_model&.name].join(" ")
  end

  def title
    @title ||= [(if name.length > 50
                   "#{name[0..50].strip}.."
                 else
                   name
                 end), device_color&.name].join(" ")
  end

  def template_attributes
    {
      name:,
      imei:,
      serial_number:,
      device_manufacturer_name: device_manufacturer&.name,
      device_model_name: device_model&.name,
      device_color_name: device_color&.name
    }
  end

  delegate :gsm_path, to: :device_model, allow_nil: true

  private

  def prevent_destroy
    return unless issues.exists?

    errors.add(:base, I18n.t(:still_in_usage, scope: "errors.messages.restrict_destroy"))
    raise StandardError, I18n.t(:still_in_usage, scope: "errors.messages.restrict_destroy")
  end

  class << self
    def reference_device(imei)
      return if imei.blank?

      Device.by_account.find_by(imei:) || Device.order(id: :desc).by_account.find_by(
        "imei like ? ", "#{imei[0..7]}%"
      )
    end
  end
end
