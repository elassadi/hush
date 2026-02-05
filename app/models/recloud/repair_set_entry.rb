class RepairSetEntry < ApplicationRecord
  include AccountOwnable
  belongs_to :repair_set
  belongs_to :article
  has_many :supplier_sources, foreign_key: :article_id, primary_key: :article_id
  validates :qty, presence: true
  validates :qty, numericality: { greater_than_or_equal_to: 1 }

  delegate :stock_status, to: :stock_service
  delegate :sku, to: :article, allow_nil: true

  before_validation :assign_tax
  after_commit :update_set_prices

  def price
    article.raw_retail_price
  end

  def total_price
    price * qty
  end

  private

  def update_set_prices
    return unless repair_set

    repair_set.update_set_price
  end

  def assign_tax
    return if tax.present?

    self.tax = article.tax if article
  end

  def stock_service
    @stock_service ||= StockService::Status.stock_service(self)
  end
end
