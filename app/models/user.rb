class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  MAX_NOTIFICATION = 5
  AVAILABLE_ACTIONS = %i[
    activate
    disable
    create_api_token
  ].freeze
  # serialize :otp_backup_codes, JSON
  # attr_accessor :otp_plain_backup_codes

  SYSTEM_USER_EMAIL = "system@hush-haarentfernung.de".freeze
  string_enum :status, %w[disabled active deleted], _default: :active
  string_enum :access_level, %w[account global], _default: :account
  string_enum :locale, %w[de en], _default: :de

  #has_paper_trail(versions: { class_name: "PaperTrail::UserVersion" }, meta: { account_id: :account_id })
  has_one_attached :avatar

  belongs_to :account
  belongs_to :merchant

  belongs_to :current_account, class_name: "Account"
  belongs_to :role

  has_many :api_tokens
  has_many :notifications, foreign_key: :receiver_id
  has_one :api_token, -> { status_active }, dependent: :delete

  has_many :customers, foreign_key: :owner_id
  has_many :issues, foreign_key: :owner_id
  has_many :issues_assigned, foreign_key: :assignee_id, class_name: "Issue"
  has_many :calendar_entries, foreign_key: :owner_id
  has_many :comments, foreign_key: :owner_id
  has_many :stock_movements, foreign_key: :owner_id
  has_many :activities, foreign_key: :owner_id

  devise :two_factor_authenticatable
  devise :timeoutable if Rails.env.production?
  devise :database_authenticatable, :registerable, :recoverable, :validatable, :confirmable, :trackable, :rememberable

  scope :system_user, -> { find_by!(email: SYSTEM_USER_EMAIL) }
  delegate :can?, :cannot?, :authorize!, :may?, to: :ability

  delegate :api?, :super_admin?, :admin?, :account_admin?, :technician?, :supervisor?, to: :role, allow_nil: true
  delegate :token, to: :api_token, allow_nil: true

  validates :status, inclusion: { in: statuses }
  validates :agb, inclusion: [true], if: :register_process_validation
  validates :account_name, presence: [true], if: :register_process_validation
  validates :avatar, content_type: ["image/jpeg", "image/png"],
                     size: { less_than: 2.megabytes }

  before_validation :assign_current_account_on_create, on: :create
  before_validation :assign_merchant_on_create, on: :create
  before_validation :check_merchant_account_constraint

  attribute :agb, :boolean
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :account_name, :string
  attribute :register_process_validation, :boolean, default: false
  before_destroy :prevent_destroy, prepend: true

  alias branch merchant
  alias confirmed confirmed?
  # validate :password_complexity

  def global_recloud_data
    @global_recloud_data ||= {
      account_id:,
      on_boarding: !account.completed_onboarding?,
      active_account: account.status_active?,
      current_user: {
        id:,
        email:,
        name:,
        role: role.name
      },
      locale: I18n.locale
    }
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def avatar_icon
    return if avatar.blank?

    # avatar.variant(resize_and_pad: [200, 200, { gravity: 'north' }])
    avatar.variant(resize_to_limit: [200, nil])
  end

  def ability
    # @ability ||= CanCanAbility.new(self)
    @ability ||= Privilege.new(self)
  end

  def apply_policy(model)
    policy = model.data_access_policy_class

    policy.resolve(user: self, model:)
  end

  def can_be_activated?
    !status_active?
  end

  def can_be_disabled?
    status_active? && Current.user != self
  end

  def can_login_as?
    status_active? && !admin?
  end

  # to check if token can be created not if user is authorized to create tokens
  # new token is activated automaticaly, old token is set to deleted
  def can_create_api_token?
    true
  end

  def remember_me
    false
  end

  # Generate an OTP secret it it does not already exist
  def generate_two_factor_secret_if_missing!
    return unless otp_secret.nil?

    update!(otp_secret: User.generate_otp_secret)
  end

  # Ensure that the user is prompted for their OTP when they login
  def enable_two_factor!
    update!(otp_required_for_login: true)
  end

  # Disable the use of OTP-based two-factor.
  def disable_two_factor!
    update!(
      otp_required_for_login: false,
      otp_secret: nil
    )
  end

  # URI for OTP two-factor QR code
  def two_factor_qr_code_uri
    issuer = ENV.fetch('OTP_2FA_ISSUER_NAME', nil)
    label = [issuer, email].join(':')

    otp_provisioning_uri(label, issuer:)
  end

  # Determine if backup codes have been generated
  def two_factor_backup_codes_generated?
    otp_backup_codes.present?
  end

  def active_for_authentication?
    confirmed? && status_active? && !api_only
  end

  def notifications_key
    [uuid, "notifications"].join
  end

  def unread_notifications?
    notifications.status_new.exists?
  end

  def top10_notifications
    notifications.status_new.limit(MAX_NOTIFICATION)
  end

  private

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/
    # regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/

    errors.add :password,
               'Das Passwort muss einen Großbuchstaben, einen Kleinbuchstaben, "\
               "eine Zahl und ein Sonderzeichen enthalten.'
  end

  def assign_current_account_on_create
    self.account_id = Current.user.current_account_id if account_id.blank?
    self.current_account_id = account_id if current_account_id.blank?
  end

  def assign_merchant_on_create
    return if merchant_id.present? && merchant.account_id == current_account_id
    return unless current_account&.merchant

    self.merchant_id = current_account.merchant.id
  end

  def check_merchant_account_constraint
    return if merchant_id.present? && merchant.account_id == current_account_id
    return unless current_account&.merchant

    self.merchant_id = current_account.merchant.id
  end

  def prevent_destroy
    return unless Current.user == self

    errors.add(:base, I18n.t('shared.messages.destroy_not_possible'))
    raise StandardError, I18n.t('shared.messages.destroy_not_possible')
  end

  def destroy # rubocop:todo Rails/ActiveRecordOverride
    return super if no_records_present?

    soft_delete!
  end

  def no_records_present?
    customers.empty? &&
      issues.empty? &&
      issues_assigned.empty? &&
      calendar_entries.empty? &&
      comments.empty? &&
      stock_movements.empty? &&
      activities.empty?
  end
end
