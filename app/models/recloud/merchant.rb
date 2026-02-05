class Merchant < ApplicationRecord
  include AccountOwnable

  string_enum :salutation, Constants::SALUTATIONS, _default: Constants::MR
  string_enum :affiliate_type, %w[master branch partner], _default: :partner

  has_many :customers
  has_many :users
  has_many :issues
  has_many :addresses, as: :addressable, dependent: :delete_all
  has_one :primary_address, -> { status_active }, as: :addressable, inverse_of: :addressable, class_name: "Address"
  has_one_attached :logo, dependent: :destroy, service: (
    ENV['AZURE_STORAGE_ACCESS_KEY'].present? ? :microsoft_public : :local
  )
  has_many :json_documents, as: :jsonable, dependent: :destroy
  has_many :business_hours, -> { where(type: 'BusinessHour') }, as: :jsonable, class_name: 'JsonDocument'

  # validates :primary_address, presence: true
  scope :master, -> { where(master: true) }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :accounting_email, format: { with: Constants::EMAIL_REGEX }
  validates :email, format: { with: Constants::EMAIL_REGEX }
  validates :logo, content_type: ["image/jpeg", "image/png"],
                   size: { less_than: 2.megabytes }

  validates :first_name, :last_name, :company_name, presence: true

  def business_hours_hsh
    BusinessHour.business_hours_hsh(self)
  end

  def title
    branch_name.presence || company_name
  end

  def contact_person
    [first_name, last_name].join " "
  end

  def logo_url
    Rails.env.development? ? local_logo_url : azure_logo_url
  end

  def local_logo_url
    return unless logo.attached?

    ActiveStorage::Current.url_options = Rails.application.config.default_url_options
    Rails.application.routes.url_helpers.rails_blob_url(
      logo,
      only_path: false,
      disposition: 'inline'
    )
  end

  def template_attributes
    {
      id:,
      uuid:,
      logo_url:,
      salutation: ::Customer.human_enum_name(:salutation, salutation),
      first_name:,
      last_name:,
      name: contact_person,
      company_name:,
      branch_name: branch_name || company_name,
      email:,
      phone_number:,
      address: primary_address&.template_attributes,
      web_page:,
      bank_name:,
      iban:,
      tax_number:,
      court_in_charge:,
      hrb_number:,
      ceo_name:
    }
  end

  def logo_path
    # Rails.application.routes.url_helpers.rails_blob_path(logo, only_path: true)
    # ActiveStorage::Current.url_options = Rails.application.config.default_url_option

    return unless logo.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      logo,
      only_path: true,
      disposition: 'inline'
    )
  end

  def _logo_url
    [
      Rails.application.config.default_url_options[:protocol],
      "://",
      Rails.application.config.default_url_options[:host],
      logo_path
    ].join
  end

  def azure_logo_url
    return unless logo.attached?
    return unless logo&.blob&.key

    require 'active_storage/service/azure_storage_service'
    client = ActiveStorage::Service::AzureStorageService.new(
      storage_account_name: ENV.fetch("AZURE_STORAGE_ACCOUNT_NAME", nil),
      storage_access_key: ENV.fetch("AZURE_STORAGE_ACCESS_KEY", nil),
      container: ENV.fetch("AZURE_STORAGE_CONTAINER", nil)
    )
    client.url(logo.blob.key, expires_in: 1.hour, disposition: 'inline',
                              filename: logo.blob.filename,
                              content_type: logo.blob.content_type)
  end
end
