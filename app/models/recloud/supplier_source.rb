class SupplierSource < ApplicationRecord
  MODEL_PREFIX = "sps".freeze
  include AccountOwnable

  # supplier sources
  INT_STOCK_STATUSES = {
    AVAILABLE = "available".freeze => 100,
    SHORTLY_AVAILABLE = "shortly_available".freeze => 90,
    UNAVAILABLE = "unavailable".freeze => 80,
    UPON_ORDER = "upon_order".freeze => 70,
    STOCK_STATUS_UNKNOWN = "unknown".freeze => 70
  }.freeze

  belongs_to :supplier
  belongs_to :article

  string_enum :unit, Constants::UNITS, _default: :piece
  string_enum :stock_status, %w[available shortly_available upon_order unavailable unknown], _default: :unknown
  has_many :supplier_articles, foreign_key: :sku, primary_key: :sku

  validates :sku, :tax, :unit, :purchase_price, presence: true

  validates :purchase_price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :supplier, uniqueness: { scope: :article }
  before_save :unset_previous_favorites, if: -> { favorite? }

  # after_save :after_stock_status_changed
  # after_save :after_purchase_price_status_changed

  after_commit :update_best_matching_supplier # , on: %i[create destroy]

  def unset_previous_favorites
    SupplierSource.where(
      account_id:,
      article_id:,
      favorite: true
    ).where.not(id:).update_all(favorite: false)
  end

  def int_stock_status
    INT_STOCK_STATUSES[stock_status].to_int
  end

  def sorted_supplier_sources
    # some how during tests the supplier_sources are not reloaded
    # article.supplier_sources.reload.sort_by do |source|
    #   [
    #     -1 * source.int_stock_status,
    #     source.favorite? ? -1 : 0,
    #     source.days_to_ship,
    #     source.purchase_price
    #   ]
    # end
    article.supplier_sources.reload.order(*SupplierSource.supplier_sorting_criteria)
  end

  def update_best_matching_supplier
    return unless sorted_supplier_sources.any?

    supplier_id = sorted_supplier_sources.first.supplier_id

    return if supplier_id == article.supplier_id && purchase_price_before_last_save == purchase_price

    article.update(supplier_id:)
    return if Rails.env.test?

    update_repair_set_prices

    PurchaseOrders::SyncBySupplierSourceOperation.call(supplier_source: self)
  end

  private

  # Service class for updating purchase orders

  def update_repair_set_prices
    supplier_source_id = id
    RepairSetEntry.includes(:repair_set).joins(:supplier_sources)
                  .where(supplier_sources: { id: supplier_source_id })
                  .find_each do |entry|
      entry.repair_set.update_set_price
    end
  end

  class << self
    def supplier_sorting_criteria
      [
        :article_id,
        Arel.sql("FIELD(stock_status, 'available','shortly_available', 'unavailable', 'upon_order', 'unknown')"),
        Arel.sql("CASE WHEN `supplier_sources`.`favorite` = 1 THEN 1 ELSE 0 END DESC "),
        :days_to_ship,
        :purchase_price
      ]
    end
  end
end
