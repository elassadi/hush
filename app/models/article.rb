class Article < ApplicationRecord
  MODEL_PREFIX = "ART".freeze
  include AccountOwnable

  store :metadata, accessors: %i[
    inventoried_history
  ], coder: JSON

  has_many_attached :images, dependent: :destroy
  belongs_to :article_group
  has_one :stock, dependent: :destroy
  has_many :stock_items, dependent: :destroy
  has_many :stock_movements, dependent: :destroy

  string_enum :status, %w[disabled active deleted], _default: :active
  string_enum :unit, Constants::UNITS, _default: :piece
  string_enum :article_type, %w[basic service freight], _default: :basic
  string_enum :pricing_strategie, %w[absolut percentage disabled], _default: :disabled

  validates :article_type, :name, :default_retail_price, presence: true
  validates :ean, uniqueness: { case_sensitive: false, scope: [:account_id] }, allow_nil: true
  validates :default_retail_price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :default_purchase_price, numericality: true, allow_nil: true
  validates :sku, presence: true, uniqueness: { case_sensitive: false, scope: [:account_id] }
  attribute :default_purchase_price, default: 0.0

  before_validation :assign_sku
  before_validation :set_min_preis_default, if: -> { min_preis.nil? }
  after_create :after_article_created
  before_destroy :prevent_destroying_still_in_usage_articles, prepend: true

  scope :stockable, -> { where(article_type: :basic) }

  belongs_to :supplier, optional: true
  belongs_to :inventoried_by, class_name: "User", optional: true
  # belongs_to :current_supplier, class_name: "Supplier", optional: true
  has_many :supplier_sources, dependent: :destroy

  has_one :supplier_source, ->(article) { where(supplier: article.supplier) }

  has_many :suppliers, through: :supplier_sources
  has_many :supplier_articles, foreign_key: :ean, primary_key: :ean
  has_many :repair_set_entries, dependent: :restrict_with_error
  has_many :repair_sets, through: :repair_set_entries
  has_many :stock_reservations

  after_commit :update_repair_set_prices

  def update_best_matching_supplier
    return unless supplier_sources.any?

    supplier_sources.first.update_best_matching_supplier
  end

  def title
    name.length > 60 ? "#{name[0...57]}..." : name
  end

  def inventoried!
    self.inventoried_history ||= []

    if inventoried_at.present? && inventoried_by_id.present?
      inventoried_history << {
        inventoried_at:,
        inventoried_by_id:
      }
    end

    # Set the current time and user as the latest inventory details
    self.inventoried_at = Time.current
    self.inventoried_by_id = Current.user.id
    save!
  end

  def inventoried?
    inventoried_at.present?
  end

  def default_purchase_price
    return self[:default_purchase_price] if supplier_source.blank?

    supplier_source.purchase_price
  end

  def purchase_price
    return default_purchase_price if supplier_source.blank?

    supplier_source.purchase_price
  end

  def retail_price
    # Beautification disabled - return raw price directly
    # tax_factor = (AppConfig::GLOBAL_TAX / 100.0) + 1
    # b = Prices::Beautifier.call(original_price: raw_retail_price * tax_factor).success
    # b / tax_factor
    raw_retail_price
  end

  def beautified_retail_price
    retail_price
  end

  def raw_retail_price
    if pricing_strategie_disabled?
      default_retail_price
    else
      margin_value + purchase_price
    end
  end

  def margin_value
    return 0.0 if pricing_strategie_disabled?

    if pricing_strategie_percentage?
      (margin * purchase_price / 100.0)
    else
      margin
    end
  end

  def stockable?
    article_type_basic?
  end

  private

  def assign_sku
    return if sku.present?

    generate_uuid if uuid.blank?
    self.sku = uuid
  end

  def set_min_preis_default
    self.min_preis = default_retail_price if default_retail_price.present?
  end

  def after_article_created
    update(stock: Stock.create(account:))
  end

  def prevent_destroying_still_in_usage_articles
    return unless RepairSetEntry.exists?(article: self)

    errors.add(:base, I18n.t(:still_in_usage, scope: "errors.messages.restrict_destroy"))
    throw(:abort)
  end

  def update_repair_set_prices
    if Rails.env.test?
      UpdateRepairSetPricesJob.perform_now(id)
    else
      UpdateRepairSetPricesJob.perform_later(id)
    end
    # article_id = id
    # RepairSetEntry.includes(:repair_set).joins(:article)
    #               .where(articles: { id: article_id })
    #               .find_each do |entry|
    #   entry.repair_set.update_set_price
    # end
  end
end
