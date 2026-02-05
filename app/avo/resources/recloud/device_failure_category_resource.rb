class DeviceFailureCategoryResource < ApplicationBaseResource
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

  self.authorization_policy = SharedDataAccessPolicy
  self.includes = []
  self.model_class = ::DeviceFailureCategory
  self.title = :name

  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(name: :asc)
  }

  field :name, as: :text
  field :description, as: :textarea

  filters [DeviceFailureCategories::NameFilter, ByAccountFilter]
end
