class PurchaseOrderResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[open],
    info: %w[in_progress],
    success: %w[done],
    warning: %w[],
    danger: %w[canceld]
  }.freeze
  # self.stimulus_controllers = "commentable entries-summary-tool"
  self.authorization_policy = ::MerchantDataAccessPolicy
  self.stimulus_controllers = "entries-summary-tool"

  self.show_controls = lambda {
    back_button
    delete_button if current_user.can?(:destroy, record)
    items = actions_list exclude: [PurchaseOrders::WorkflowAction]
    if current_user.can?(:edit_workflow,
                         record) && PurchaseOrders::PurchaseOrderWorkflow.human_workflow_event_names(record).any?
      action PurchaseOrders::WorkflowAction, style: :primary, color: :primary, icon: "heroicons/outline/cog-6-tooth"
    end
    edit_button if current_user.can?(:edit, record)
    items
  }

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(created_at: :desc)
  }

  self.includes = []

  field :status, as: :status_badge, options: lambda { |model:, resource:|
    model.workflow.class.options
  }

  field :status_category, as: :status_badge, options: STATUS_OPTIONS
  field :linked_purchase_order, as: :belongs_to, only_on: :show, visible: lambda { |resource:|
    resource.record.linked_purchase_order.present?
  }
  field :supplier, as: :belongs_to, in_line: :create, attach_scope: -> { query.by_account }

  field :purchase_order_entries, as: :has_many, modal_create: true
  tool EntriesSummaryTool

  field :linked_purchase_orders, as: :has_many

  field :created_at, as: :date_time, only_on: :index

  field :comments, as: :has_many, modal_create: true

  #  tool CommentableTool

  filter ::BaseStatusFilter, arguments: { model_class: PurchaseOrder, status_field_name: :status_category }
  filter ::PurchaseOrders::SupplierFilter
  filter ::PurchaseOrders::SkuFilter
  actions(::PurchaseOrders::SplitAction)
end
