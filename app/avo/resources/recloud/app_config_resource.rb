class AppConfigResource < ApplicationBaseResource
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.title = :key
  self.includes = []

  field :id, as: :id
  field :key, as: :text
  field :value, as: :textarea

  filter ::AppConfigKeyFilter
end
