class Role < ApplicationRecord
  include AccountOwnable
  EXCLUDED_ROLES = %w[super_admin public_api trail_basic_account_admin on_boarding].freeze

  self.inheritance_column = :_type_disabled

  string_enum :status, %w[disabled active deleted], _default: :active
  string_enum :type, %w[customer system], _default: :customer

  # has_many :abilities, dependent: :restrict_with_error
  has_many :abilities, dependent: :delete_all

  scope :visible_for_customer, lambda {
    where(type: "customer", status: :active).where.not(name: Role::EXCLUDED_ROLES)
  }

  def can_sync_customer_roles?
    type_customer? && status_active?
  end

  def super_admin?
    name == "super_admin"
  end

  def api?
    name == "public_api" ||
      name == "private_api"
  end

  def admin?
    super_admin? || name == "admin"
  end

  def account_admin?
    admin? || name == "account_admin"
    # || name == "free_account_admin"
  end

  def agent?
    name == "agent"
  end

  def supervisor?
    name == "supervisor"
  end
end
