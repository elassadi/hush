class Address < ApplicationRecord
  include AccountOwnable
  AVAILABLE_ACTIONS = %i[
    activate
  ].freeze

  string_enum :status, %w[draft active archived], _default: :draft

  has_paper_trail(versions: { class_name: "PaperTrail::AddressVersion" }, meta: { account_id: :account_id })
  belongs_to :addressable, polymorphic: true

  validates :country, length: { maximum: 3 }
  validates :street, :city, :post_code, presence: true
  validates :post_code, numericality: { only_integer: true }, allow_blank: true
  validates :post_code, length: { is: 5 }, allow_blank: true

  before_save :ensure_first_address_to_be_active
  after_create :activate_address
  # before_destroy :prevent_destroy, prepend: true

  after_create :onboard_steps

  def one_liner
    "#{street} #{house_number}, #{post_code} #{city}"
  end

  def can_be_activated?
    !status_active?
  end

  def street_address
    "#{street} #{house_number}"
  end

  def template_attributes
    {
      street_address:,
      post_code:,
      city:,
      country:
    }
  end

  private

  def onboard_steps
    return unless addressable.is_a?(Merchant)
    return unless addressable.addresses.count == 1 # This is the first address

    # TODO: Refactor this to an operation
    account.update(completed_onboarding: true)
  end

  def activate_address
    return if status_active?

    Addresses::ActivateTransaction.call(address_id: id)
  end

  def ensure_first_address_to_be_active
    return if Address.exists?(addressable:)

    self.status = :active
  end

  # def assign_account
  #   return if account_id
  #   return unless addressable

  #   self.account_id = if addressable.is_a?(Account)
  #                       addressable.id
  #                     else
  #                       addressable.account_id
  #                     end
  # end

  def prevent_destroy
    return unless status_active?

    errors.add(:base, I18n.t('shared.messages.destroy_not_possible'))
    raise StandardError, "Address is still active"
  end
end
