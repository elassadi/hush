class EventJobResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[success],
    warning: %w[processing],
    danger: %w[failure]
  }.freeze

  self.title = :klass_name
  self.stimulus_controllers = "hello"

  self.includes = []
  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :status, as: :status_badge, options: STATUS_OPTIONS

  field :klass_name, as: :text
  field :event_name, as: :text
  field :event, as: :belongs_to
  field_date_time  :updated_at, show_seconds: true
  field :result, as: :text, only_on: :show
  field :data, stacked: true, theme: "eclipse", as: :code, language: 'javascript' do |model|
    JSON.pretty_generate(model.data.as_json) if model.data.present?
  end

  filter ::BaseStatusFilter, arguments: { model_class: EventJob }
  action DeleteAction
end
