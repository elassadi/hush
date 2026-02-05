class RoleResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[customer],
    success: %w[active],
    warning: %w[],
    danger: %w[unknown system]
  }.freeze

  self.title = :name
  self.includes = []

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :type, as: :status_badge, options: STATUS_OPTIONS
  field :name, as: :text

  field :abilities, as: :has_many

  # action Roles::SyncCustomerRoleAction
  filter ByAllAccountFilter
  filter Roles::ByRoleFilter
end
