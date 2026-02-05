class EventResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[pending],
    success: %w[success],
    warning: %w[retry],
    danger: %w[failure]
  }.freeze

  self.title = :name
  self.includes = []

  field :id, as: :id

  field :status, as: :select, hide_on: %i[show index],
                 options: ->(_args) { ::Event.human_enum_names(:status).invert }, display_with_value: true

  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :retry_counter, as: :number

  field :name, as: :text
  field :klass_name, as: :text
  field :prio, as: :number
  field_date_time  :updated_at, show_seconds: true

  field :event_jobs, as: :has_many

  filter ::BaseStatusFilter, arguments: { model_class: Event }
  filter ::Events::NameFilter
  filter ::Events::KlassNameFilter

  actions [DeleteAction, Events::RetryAction]
end
