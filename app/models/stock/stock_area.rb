class StockArea < ApplicationRecord
  MODEL_PREFIX = "sta".freeze
  include AccountOwnable

  DEFAULT_RECENT_COUNT = 10

  validates :name, presence: true, uniqueness: { scope: [:account_id], case_sensitive: false }
  belongs_to :stock_location, inverse_of: :stock_areas
  has_many :stock_items, inverse_of: :stock_area
  has_many :stock_movements, through: :stock_items

  before_destroy :prevent_destroy

  def full_name
    "#{stock_location.name}-#{name}"
  end

  def prevent_destroy
    return if stock_items.blank?

    errors.add(:base, I18n.t(:has_many,
                             record: StockItem.model_name.human,
                             scope: "activerecord.errors.messages.restrict_dependent_destroy"))
    throw(:abort)
  end

  def in_stock
    stock_items.sum(:in_stock)
  end

  def recent_stock_movements(limit: DEFAULT_RECENT_COUNT)
    stock_movements.includes(%i[user article])
                   .limit(limit)
                   .order(created_at: :desc)
  end
end
