class StockLocation < ApplicationRecord
  MODEL_PREFIX = "stl".freeze
  include AccountOwnable

  validates :name, presence: true, uniqueness: { scope: %i[account_id] }
  has_many :stock_areas, inverse_of: :stock_location

  before_save :ensure_primary
  before_destroy :prevent_destroying_primary_record
  before_destroy :prevent_destroying_location_with_stock_areas

  def ensure_primary
    # we cant not set to false
    if primary_was
      self.primary = true
      return
    end

    self.primary = true unless primay_exists?

    account.stock_locations.where.not(id:).update_all(primary: false) if primary
  end

  def primay_exists?
    account.stock_locations.where.not(id:).where(primary: true).present?
  end

  def prevent_destroying_location_with_stock_areas
    return if stock_areas.blank?

    errors.add(:base, I18n.t(:has_many,
                             record: StockItem.model_name.human,
                             scope: "activerecord.errors.messages.restrict_dependent_destroy"))
    throw(:abort)
  end

  def prevent_destroying_primary_record
    return unless primary

    errors.add(:base, I18n.t(:primary,
                             record: StockItem.model_name.human,
                             scope: "activerecord.errors.messages.restrict_dependent_destroy"))
    throw(:abort)
  end

  class << self
    def primary
      find_by(primary: true)
    end
  end
end
