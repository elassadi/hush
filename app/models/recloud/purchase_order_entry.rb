class PurchaseOrderEntry < ApplicationRecord
  MODEL_PREFIX = "pre".freeze
  include AccountOwnable

  attr_accessor :split_mode

  belongs_to :article
  belongs_to :purchase_order

  belongs_to :stock_reservation, class_name: 'StockReservation', foreign_key: :originator_id, optional: true
  has_one :issue_entry, through: :stock_reservation
  has_one :issue, through: :issue_entry

  belongs_to :originator, polymorphic: true, optional: true
  # before_destroy :prevent_destroying_active_items, prepend: true
  validates :qty, numericality: { greater_than_or_equal_to: 1 }

  delegate :sku, to: :article, allow_nil: true

  def supplier_sku
    article.supplier_sources.find_by(supplier: purchase_order.supplier)&.sku
  end

  def total_price
    price * qty
  end

  # def _issue
  #   return if initiator.blank?
  #   return unless initiator.is_a?(StockReservation)

  #   issue_entry = initiator.initiator
  #   return unless issue_entry.is_a?(::RepairOrder::RepairOrderEntry)

  #   issue_entry.issue
  # end

  # def prevent_destroying_active_items
  #   return if purchase_order.status_category_open?

  #   errors.add(:base, I18n.t(:still_in_usage, scope: "errors.messages.restrict_destroy"))
  #   throw(:abort)
  # end
end
