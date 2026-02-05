class DeviceModelCategoryResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.title = :name
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  field :name, as: :text
  field :description, as: :textarea

  filters [DeviceModelCategories::NameFilter, ByAccountFilter]
end
