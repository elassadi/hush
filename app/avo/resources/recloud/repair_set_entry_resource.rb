class RepairSetEntryResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField

  STOCK_OPTIONS = {
    gray: %w[shortly_available],
    info: %w[ordered delivered],
    success: %w[available],
    warning: %w[reserved will_be_ordered can_be_ordered upon_order],
    danger: %w[unavailable unknown]
  }.freeze

  self.includes = [:article]
  self.stimulus_controllers = "repair-set-resource"
  self.title = :name

  field :repair_set_entry_details, as: :heading
  field :stock_status, as: :status_badge, options: STOCK_OPTIONS,
                       hide_on: %i[edit new], shorten: false

  field :repair_set, as: :belongs_to
  field :article, as: :belongs_to, searchable: true
  field :sku, as: :uuid, link_to_resource: false
  field :qty, as: :number, default: 1
  field :price, as: :price, only_on: :index, input_mode: :brutto
  field :total_price, as: :price, only_on: :index, input_mode: :brutto
end
