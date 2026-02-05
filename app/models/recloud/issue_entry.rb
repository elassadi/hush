class IssueEntry < ApplicationRecord
  MODEL_PREFIX = "ise".freeze
  include AccountOwnable

  string_enum :category, %w[article repair_set text rabatt], _default: :article

  belongs_to :issue

  belongs_to :article, optional: true

  belongs_to :repair_set_entry, optional: true
  has_one :stock_reservation, as: :originator
  has_one :repair_set, through: :repair_set_entry
  attribute :repair_set_id, :integer, default: nil
  validates :price, numericality: { greater_than_or_equal_to: 0.00 }
  validates :qty, :article_name, :price, presence: true
  scope :stockable, -> { joins(:article).where(articles: { article_type: 'basic' }) }

  before_destroy :broadcast_destroy_event
  after_destroy :broadcast_after_destroy_event
  after_commit :remove_rabatt_entry
  after_update_commit :broadcast_update_event

  def broadcast_update_event
    Event.broadcast(:issue_entry_updated, issue_entry_id: id)
  end

  def broadcast_destroy_event
    Event.broadcast(:issue_entry_destroyed, issue_entry_id: id, stock_reservation_id: stock_reservation&.id)
  end

  def broadcast_after_destroy_event
    Event.broadcast(:after_issue_entry_destroyed, issue_id: issue.id)
  end

  delegate :stock_is_available?, to: :stock_service
  delegate :stockable?, to: :article, allow_nil: true
  delegate :sku, to: :article, allow_nil: true

  delegate :stock_status, to: :stock_service

  def template_attributes
    {
      id:,
      pos: position,
      name: article_name,
      total:,
      price:,
      qty:
    }
  end

  def title
    return unless article_name

    article_name.length > 60 ? "#{article_name[0...57]}..." : article_name
  end

  def total
    price * qty
  end

  private

  def position
    issue.issue_entries.order(:created_at).pluck(:id).index(id) + 1
  end

  def remove_rabatt_entry
    return unless category_rabatt?

    delete if price < 0.0
  end

  def stock_service
    @stock_service ||= StockService::Status.stock_service(self)
  end
end
