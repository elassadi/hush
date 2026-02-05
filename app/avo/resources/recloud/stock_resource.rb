class StockResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  # include Concerns::AccountField
  # include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.includes = %i[article account]

  field :article, as: :belongs_to
  field :in_stock, as: :text
  field :in_stock_available, as: :text
  field :reserved, as: :text
  field :in_stock_each_area, as: :key_value,
                             key_label: I18n.t(:in_stock_each_area, scope: "activerecord.attributes.stock"),
                             value_label: I18n.t(:in_stock, scope: "activerecord.attributes.stock"), stacked: true

  sidebar do
    %i(updated_at created_at).each do |field_name|
      sidebar_field_date_time self, field_name, show_seconds: true, visible: lambda { |resource:|
        next unless resource && resource.model

        resource && resource.model[field_name].present?
      }
    end
  end

  filter Stocks::NameFilter
  action Stocks::ExportAction
  action ::CloneAction
end
