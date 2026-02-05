class StockReservation < ApplicationRecord
  include AccountOwnable

  PRIO_HIGH = 100
  PRIO_NORMAL = 10
  PRIO_LOW = 0

  MODEL_PREFIX = "str".freeze

  ACTIONS = [
    RELEASE = "release".freeze
  ].freeze

  string_enum :status, %w[pending reserved fulfilled], _default: :stock_in

  belongs_to :article
  has_one    :stock, through: :article

  belongs_to :issue_entry, class_name: 'IssueEntry', foreign_key: :originator_id, optional: true
  has_one :issue, through: :issue_entry

  belongs_to :originator, polymorphic: true, optional: true
  validates :qty, numericality: { greater_than_or_equal_to: 1 }

  has_one :purchase_order_entry, as: :originator
  has_one :purchase_order, through: :purchase_order_entry

  attribute :prio_badge, :string

  def issue
    originator.respond_to?(:issue) ? originator.issue : originator
  end

  def temporary?
    prio < PRIO_NORMAL
  end

  def prio_badge
    case prio
    when PRIO_HIGH
      "high"
    when PRIO_NORMAL
      "normal"
    when PRIO_LOW
      "low"
    end
  end

  class << self
  end
end
