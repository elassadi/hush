class PurchaseOrder < ApplicationRecord
  MODEL_PREFIX = "pro".freeze
  include AccountOwnable
  include MerchantOwnable

  AVAILABLE_ACTIONS = %i[
    activate
    print_kva
  ].freeze

  has_paper_trail(meta: { account_id: :id })

  store :metadata, accessors: %i[], coder: JSON
  string_enum :status_category, %w[open in_progress done], _default: :open
  # possible values : [ draft ordered  delivered canceld]
  # see workflow purchase_order.yaml
  attribute :status, :string, default: 'draft'

  belongs_to :supplier
  has_many :comments, as: :commentable, dependent: :delete_all
  has_many :purchase_order_entries, ->(record) { where(account_id: record.account_id) }, dependent: :delete_all
  has_many :all_purchase_order_entries, class_name: 'PurchaseOrderEntry'

  belongs_to :linked_purchase_order, class_name: 'PurchaseOrder', optional: true, foreign_key: :linked_to_id
  has_many :linked_purchase_orders, class_name: 'PurchaseOrder', foreign_key: :linked_to_id

  attribute :tax, default: proc { AppConfig::GLOBAL_TAX }

  before_destroy :prevent_destroying_active_orders, prepend: true
  delegate :run_event!, :can_run_event?, to: :workflow

  alias :summary_entries :purchase_order_entries

  def workflow
    @workflow ||= PurchaseOrders::PurchaseOrderWorkflow.create(self)
  end

  def price
    purchase_order_entries.pick(
      Arel.sql(" sum(price * qty) as total ")
    ).to_f
  end

  def status_ordered?
    status == 'ordered'
  end

  def status_delivered?
    status == 'delivered'
  end

  def status_draft?
    status == 'draft'
  end

  private

  def prevent_destroying_active_orders
    return if status_category_open?

    errors.add(:base, I18n.t(:still_in_usage, scope: "errors.messages.restrict_destroy"))
    throw(:abort)
  end
end
