class SupplierArticleResource < ApplicationBaseResource
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  ALL_OPTIONS = {
    gray: %w[stueck basic unknown],
    info: %w[],
    success: %w[active available],
    warning: %w[service freight pre_order shortly_available upon_order],
    danger: %w[disabled deleted unavailable]
  }.freeze

  self.translation_key = "activerecord.attributes.supplier_article"
  self.authorization_policy = SharedDataAccessPolicy
  self.title = :article_name
  self.includes = [:account]

  self.hide_from_global_search = true
  self.search_query = lambda {
    scope.ransack(article_name_matches: "%#{params[:q]}%", m: "or").result(distinct: false)
  }

  field :stock_status, as: :status_badge, options: ALL_OPTIONS
  field :stock_status, as: :select, hide_on: %i[show index],
                       options: ->(_args) { ::SupplierSource.human_enum_names(:stock_status).invert },
                       display_with_value: true, include_blank: false

  field :supplier, as: :belongs_to
  field :article_name, as: :text
  field :sku, as: :uuid, shorten: false, link_to_resource: false
  field :supplier_article_group, as: :text
  field :article_description, as: :textarea

  field :ean, as: :text, hide_on: :index
  field :sku, as: :text, hide_on: :index
  field :tax, as: :number, default: 19.0, hide_on: :index
  field :unit, as: :status_badge, options: ALL_OPTIONS, hide_on: :index
  field :unit, as: :select, hide_on: %i[show index],
               options: ->(_args) { ::SupplierSource.human_enum_names(:unit).invert }, display_with_value: true,
               include_blank: false

  field :purchase_price, as: :price

  filter Articles::SkuFilter
  action ::CloneAction
  action SupplierArticles::ImportAction
  action SupplierArticles::AddToArticlesAction
end
