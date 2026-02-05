class Customer < ApplicationRecord
  MODEL_PREFIX = "cus".freeze
  include AccountOwnable
  include UserOwnable
  include MerchantOwnable
  attr_accessor :skip_address_validation

  RECENT_LIMIT = 10

  string_enum :salutation, Constants::SALUTATIONS

  string_enum :status, %w[disabled active deleted], _default: :active

  has_many :addresses, as: :addressable, dependent: :delete_all
  has_many :comments, as: :commentable, dependent: :delete_all
  has_many :issues
  has_many :devices, -> { distinct }, through: :issues

  belongs_to :merchant

  has_one :primary_address, -> { status_active }, as: :addressable, inverse_of: :addressable,
                                                  class_name: "Address"

  attribute :street, :string
  #validates :street, presence: true, on: :create, unless: :skip_address_validation
  #validates :city, presence: true, on: :create, unless: :skip_address_validation
  #validates :post_code, presence: true, on: :create, unless: :skip_address_validation


  attribute :house_number, :string
  attribute :city, :string
  attribute :post_code, :string


  validates :phone_number, format: { with: Constants::PHONE_REGEX }, allow_blank: true
  validates :mobile_number, presence: true
  validates :mobile_number, format: { with: Constants::PHONE_REGEX }
  # validates :mobile_number, uniqueness: { scope: [:account_id,
  # :active_record] }, allow_blank: true, if: :status_active?

  validate :mobile_number_uniqueness
  validate :email_uniqueness

  validates :post_code, numericality: { only_integer: true }, allow_blank: true

  validates :email, format: { with: Constants::EMAIL_REGEX }, allow_blank: true

  validates :first_name, :last_name, presence: true, if: proc { |customer|
    customer.salutation != Constants::CO
  }
  validates :salutation, presence: true

  validates :post_code, length: { is: 5 }, allow_blank: true
  validates :company_name, presence: true, if: proc { |customer|
    customer.salutation == Constants::CO
  }

  validates :company_name, length: {
    maximum: proc { columns_hash["company_name"].limit }
  }

  before_validation :sanitize_mobile_number
  before_validation :generate_dummy_email_if_blank

  scope :merchant_customers, -> { where(merchant_id: User.current_user.merchant_id) }

  # Draft

  belongs_to :draft_device_model, class_name: "DeviceModel", optional: true
  belongs_to :draft_device_color, class_name: "DeviceColor", optional: true

  delegate :count, to: :issues, prefix: true

  def destroy # rubocop:todo Rails/ActiveRecordOverride
    return super if issues.empty?

    soft_delete!
  end

  def title
    str = if salutation_company?
            company_name || ([first_name, last_name].join " ")
          else
            [first_name, last_name].join " "
          end
    if str.length > 24
      "#{str[0..20].strip}.."
    else
      str
    end
  end

  def name
    [first_name, last_name].join " "
  end

  def dropdown_name
    [first_name, last_name, "/", email, "[#{id}]"].join " "
  end

  def collection_dropdown_name
    [first_name, last_name, company_name, "/", email, "[#{id}]"].join " "
  end

  def template_attributes
    {
      id:,
      uuid:,
      sequence_id:,
      salutation: ::Customer.human_enum_name(:salutation, salutation),
      first_name:,
      last_name:,
      name:,
      company_name:,
      email:,
      phone_number:,
      mobile_number:,
      address: primary_address&.template_attributes
    }
  end

  def house_number
    primary_address&.house_number
  end

  private

  def sanitize_mobile_number
    self.mobile_number = mobile_number.delete('+') if mobile_number.present?
  end

  def generate_dummy_email_if_blank
    return if email.present?
    return unless mobile_number.present?

    # Generate dummy email using mobile number
    # Remove any non-digit characters from mobile number for email
    clean_mobile = mobile_number.to_s.gsub(/\D/, '')
    return if clean_mobile.blank?

    self.email = "#{clean_mobile}@hush-haarentfernung.de"

  end

  def email_uniqueness
    return unless status_active?

    existing_customer = Customer.where(account_id:,
                                       email:, active_record: true).where.not(id:).first

    return if existing_customer.blank?

    errors.add(:email, :taken)
  end

  def mobile_number_uniqueness
    return if mobile_number.blank?
    return unless status_active?

    # Check if another customer with the same mobile_number and account_id exists
    existing_customer = Customer.where(account_id:,
                                       mobile_number:, active_record: true).where.not(id:).first

    return if existing_customer.blank?

    errors.add(:mobile_number, :taken)
  end

  class << self
    def search_by_name_or_phone(input_str)
      quick_search = QuickSearch::Customer.new(search_options: nil, input_str:)
      quick_search.perform_all(max_hit: 20)
    end

    def recent
      relation = if User.current_user.admin?
                   Customer.all
                 else
                   User.current_user.customers
                 end
      relation.includes(:merchant).order(id: :desc).limit(RECENT_LIMIT)
    end

    def to_select
      merchant_customers.limit(1000).select(:id, :email, :first_name, :last_name)
    end
  end
end
