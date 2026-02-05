class StockMovementResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[stock_in],
    warning: %w[stock_out],
    danger: %w[unknown]
  }.freeze

  self.title = :uuid
  self.includes = %i[account article stock_area stock_location]
  self.model_class = StockMovement
  self.authorization_policy = GlobalDataAccessPolicy
  self.stimulus_controllers = "stock-movement-resource"

  field :action, as: :status_badge, options: STATUS_OPTIONS
  field :action, as: :select, hide_on: %i[show index],
                 options: ->(_args) { ::StockMovement.human_enum_names(:action).invert },
                 display_with_value: true, include_blank: false,
                 default: lambda {
                   if params[:stock_out].present?
                     "stock_out"
                   else
                     record.action
                   end
                 }

  field :action_type, as: :status_badge, options: STATUS_OPTIONS, hide_on: :index
  EXCLUDED_ACTION_TYPES = %w[stock_without_referenz].freeze
  field :action_type, as: :select, hide_on: %i[show index],
                      options: lambda { |_args|
                                 values = ::StockMovement.human_enum_names(:action_type)
                                 result = values.reject { |s| EXCLUDED_ACTION_TYPES.include?(s) }.invert
                                 result
                               },
                      display_with_value: true, include_blank: false

  field :article, as: :belongs_to, searchable: true,
                  html: {
                    edit: {
                      input: {
                        data: {
                          action: "stock-movement-resource#onArticleChange"
                        }
                      }
                    }
                  }
  field :sku, as: :text, hide_on: %i[show index], visible: ->(args) { args[:resource].model.article.blank? }
  field :ean, as: :text, hide_on: %i[show index], visible: ->(args) { args[:resource].model.article.blank? }

  field :qty, as: :number, help: lambda { |resource:, orig_help:|
    if resource&.model && resource.model.article
      I18n.t('helpers.stock_movement.total_in_stock', count: resource.model.article.stock.in_stock)
    end
  }

  field :stock_location, as: :belongs_to, hide_on: :index, attach_scope: -> { query.by_account },
                         html: {
                           edit: {
                             input: {
                               data: {
                                 action: "stock-movement-resource#onStockLocationChange"
                               }
                             }
                           }
                         }
  field :stock_area, as: :belongs_to, attach_scope: -> { query.by_account }, hide_on: :index

  field :issue, as: :uuid, as_html: true, link_to_resource: false do |model|
    next unless model.issue

    Avo::App.view_context.link_to "REP-#{model.issue.sequence_id}", "/resources/issues/#{model.issue.id}"
  end

  field :originator, as: :belongs_to, polymorphic_as: :originator, types: [::IssueEntry, ::PurchaseOrderEntry],
                     only_on: :show
  field :owner, as: :belongs_to, hide_on: %i[forms]
  field :created_at, as: :date_time, only_on: :index
end
