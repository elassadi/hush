class SmsQueueResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[pending],
    info: %w[queued],
    success: %w[delivered received],
    warning: %w[sent],
    danger: %w[failed]
  }.freeze

  self.title = :id
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy

  self.includes = []

  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :to, as: :text
  field :message_teaser, as: :text, only_on: :index
  field :message, as: :text, only_on: :show
  # field :status, as: :select, hide_on: %i[show index],
  #                options: lambda { |_args|
  #                           ::Ability.human_enum_names(:status, translate: false).invert
  #                         }, display_with_value: true,
  #                placeholder: :please_select_ability, include_blank: false

  filter ByAllAccountFilter
  filter ::BaseStatusFilter, arguments: { model_class: SmsQueue }
end
