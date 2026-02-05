class StockMovement < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "stm".freeze
  AUTO_IMPORT = true

  ACTIONS = [
    STOCK_IN = "stock_in".freeze,
    STOCK_OUT = "stock_out".freeze
  ].freeze

  string_enum :action, %w[stock_in stock_out], _default: :stock_in
  string_enum :action_type, %w[stock_without_referenz stock_with_referenz retoure defective],
              _default: :stock_without_referenz

  belongs_to :issue_entry, class_name: 'IssueEntry', foreign_key: :originator_id, optional: true
  has_one :issue, through: :issue_entry

  belongs_to :originator, polymorphic: true, optional: true
  belongs_to :stock_item, optional: true
  belongs_to :owner, class_name: "User"
  belongs_to :article
  belongs_to :stock_location
  belongs_to :stock_area

  validates :qty, numericality: { greater_than_or_equal_to: 1 }
  validate :validate_stock_out_pre_conditions

  attr_reader :sku, :ean

  attribute :owner_id, :integer, default: proc { Current.user.id }

  attribute :qty, :integer, default: 1
  after_commit :execute_stock_actions, on: :create

  def sku=(value)
    @sku = value
    return if article.present? || value.blank?

    self.article = Article.find_by(sku: value)
    return if article.present?

    errors.add(:sku, I18n.t(:record_not_found,
                            scope: "messages", model: Article.model_name.human))
  end

  def ean=(ean_value)
    @ean = ean_value

    return if article.present? || ean.blank?

    self.article = Article.find_by(ean:)
    self.article ||= import_article(ean) if AUTO_IMPORT

    return if article.present?

    errors.add(
      :ean,
      I18n.t(:record_not_found,
             scope: "messages", model: Article.model_name.human)
    )
  end

  def import_article(ean)
    supplier_article = SupplierArticle.find_by(ean:)

    return unless supplier_article

    supplier_article.article if supplier_article.import_article
  end

  def execute_stock_actions
    Event.broadcast(:stock_movement_created, stock_movement_id: id)
  end

  private

  def validate_stock_out_pre_conditions
    return if errors.any? || action != STOCK_OUT

    return validate_stock_out_pre_conditions_for_manual_stock_out unless action_type_stock_with_referenz?

    available_qty = article.stock.in_stock

    return if available_qty >= qty

    if available_qty.zero?
      errors.add(:qty, I18n.t(
                         :stock_empty,
                         scope: "activerecord.errors.models.stock_movement"
                       ))
    else
      errors.add(:qty, I18n.t(
                         :stock_out_min_qty,
                         scope: "activerecord.errors.models.stock_movement",
                         qty: available_qty
                       ))
    end
  end

  def validate_stock_out_pre_conditions_for_manual_stock_out
    available_qty = article.stock.in_stock_by_area(stock_area)

    return if available_qty >= qty

    if available_qty.zero?
      errors.add(:qty, :stock_empty)
    else
      errors.add(:qty, :stock_out_min_qty, qty: available_qty)
    end
  end
end
