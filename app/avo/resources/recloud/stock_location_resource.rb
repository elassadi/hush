class StockLocationResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.title = :name

  field :name, as: :text
  field :stock_areas, as: :has_many
  field :primary, as: :boolean

  # field :versions, as: :has_many, use_resource: ContractVersionResource, is_readonly: true
  # filter ::Contracts::StatusFilter
  # action ::Contracts::CreatePayment
end
