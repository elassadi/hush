class ApiTokenResource < ApplicationBaseResource
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(last_used_at created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[],
    info: %w[],
    success: %w[active],
    warning: %w[],
    danger: %w[deleted]
  }.freeze

  self.title = :id
  self.includes = []

  field :id, as: :id
  field :token, as: :uuid, shorten: false
  field :status, as: :status_badge, options: STATUS_OPTIONS
end
