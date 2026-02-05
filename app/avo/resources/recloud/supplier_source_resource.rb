class SupplierSourceResource < ApplicationBaseResource
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  ALL_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[available],
    warning: %w[shortly_available upon_order],
    danger: %w[unavailable]
  }.freeze

  self.title = :sku

  self.includes = [:supplier]
  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.supplier_source"

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :stock_status, as: :status_badge, options: ALL_OPTIONS
  field :stock_status, as: :select, hide_on: %i[show index],
                       options: ->(_args) { ::SupplierSource.human_enum_names(:stock_status).invert },
                       display_with_value: true, include_blank: false
  field :sku, as: :uuid, shorten: false, link_to_resource: false

  field :article, as: :belongs_to, in_line: :create, attach_scope: -> { query.by_account }, searchable: true,
                  stimulus: { action: "issue-entry-resource#onArticleChange", view: %i[new edit] }
  field :supplier, as: :belongs_to, in_line: :create, attach_scope: -> { query.by_account }
  field :article_name, as: :text, hide_on: :index
  field :article_description, as: :textarea
  field :sku, as: :text, hide_on: :index
  field :tax, as: :number, default: 19.0, hide_on: :index
  field :unit, as: :status_badge, options: ALL_OPTIONS, hide_on: :index
  field :unit, as: :select, hide_on: %i[show index],
               options: ->(_args) { ::SupplierSource.human_enum_names(:unit).invert }, display_with_value: true,
               include_blank: false

  field :purchase_price, as: :price, default: "0.0", input_mode: :netto
  field :favorite, as: :boolean
end
