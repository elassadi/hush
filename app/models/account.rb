class Account < ApplicationRecord
  has_paper_trail(meta: { account_id: :id })
  MODEL_PREFIX = "acc".freeze

  store :metadata, accessors: %i[completed_onboarding onboarding_steps], coder: JSON

  has_many :roles
  has_many :stock_locations
  has_many :stock_areas
  has_many :users
  has_many :documents, as: :documentable, inverse_of: :documentable
  has_many :addresses, as: :addressable, dependent: :delete_all
  has_one :primary_address, -> { status_active }, as: :addressable, inverse_of: :addressable, class_name: "Address"
  scope :recloud, -> { find_by!(uuid: Constants::RECLOUD_ACCOUNT_UUID) }
  has_one :merchant, -> { where(master: true) }
  has_one :master_merchant, -> { where(master: true) }, class_name: "Merchant"
  has_one :user, -> { where(master: true) }
  has_many :settings
  has_many :merchants
  has_many :branches, -> { where(affiliate_type: %i[branch master]) }, class_name: "Merchant"

  string_enum :status, %w[disabled pending_verification active deleted], _default: :pending_verification
  string_enum :account_type, %w[recloud customer]
  string_enum :plan, %w[free basic advanced unlimited], _default: :free
  string_enum :legal_form, %w[GmbH Einzelunternehmen UG(haftungsbeschränkt) Gmbh&Co.KG Einzelfirma]

  validates :name, presence: true, uniqueness: true
  validates :status, inclusion: { in: statuses }
  validates :account_type, inclusion: { in: account_types }
  validates :legal_form, inclusion: { in: legal_forms }

  alias branch merchant

  def recloud?
    uuid == Constants::RECLOUD_ACCOUNT_UUID
  end

  def completed_onboarding?
    completed_onboarding
  end

  def can_be_activated?
    status_pending_verification? || status_disabled?
  end

  def can_be_disabled?
    status_active?
  end

  def global_settings
    settings.find_by(category: :global) || settings.create(category: :global)
  end

  def application_settings
    settings.find_by(category: :application) || settings.create(category: :application)
  end

  def booking_settings
    settings.find_by(category: :booking) || settings.create(category: :booking)
  end

  def public_token
    return unless public_user

    public_user.token
  end

  def public_user
    users.status_active.joins(:role).where(roles: { name: :public_api }).first
  end

  def feature_not_available?(feature)
    !feature_available?(feature)
  end

  def feature_available?(feature)
    features_by_plan == :all || features_by_plan.include?(feature)
  end

  private

  def features_by_plan
    return :all if plan_unlimited?

    {
      free: %i[],
      basic: %i[external_smtp sms_notifications insurance issue_locking document_footer],
      advanced: %i[external_smtp sms_notifications insurance issue_locking document_footer]
    }[plan.to_sym]
  end
end
