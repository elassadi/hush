class SideBarStockResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  # include Concerns::AccountField
  # include Concerns::DateResourceSidebar

  self.model_class = ::Stock

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.includes = %i[article account]
  field :in_stock, as: :text
  field :in_stock_available, as: :text
  field :reserved, as: :text
  field :in_stock_each_area, as: :key_value,
                             key_label: I18n.t(:in_stock_each_area, scope: "activerecord.attributes.stock"),
                             value_label: I18n.t(:in_stock, scope: "activerecord.attributes.stock"), stacked: true

  filter Stocks::NameFilter
  action Stocks::ExportAction
  action ::CloneAction
end
