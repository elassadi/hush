class NotificationResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.authorization_policy = NotificationDataAccessPolicy

  STATUS_OPTIONS = {
    gray: %w[],
    info: %w[new],
    success: %w[read],
    warning: %w[],
    danger: %w[deleted]
  }.freeze

  self.includes = []

  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :receiver, as: :belongs_to, visible: ->(_args) { Current.user.admin? }
  field :sender, as: :belongs_to, hide_on: :forms
  field :sent_at, as: :text, format_using: lambda { |value|
                                             I18n.t(:ago, scope: "datetime.distance_in_words", distance: value)
                                           }, hide_on: :forms
  field :title, as: :text, format_using: ->(value) { ActionController::Base.helpers.sanitize(value) }

  filter ::BaseStatusFilter, arguments: { model_class: Notification }
end
