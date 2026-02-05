class WebhookRequestResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray: %w[skipped],
    info: %w[pending],
    success: %w[success],
    warning: %w[retry],
    danger: %w[failure]
  }.freeze

  self.title = :id
  self.includes = []

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :retry_counter, as: :number
  field :event, as: :text
  field :type, as: :text

  field :payment, as: :belongs_to
  field :contract, as: :belongs_to
  field_date_time  :updated_at, show_seconds: true

  field :body, theme: "eclipse", as: :code, height: "350px", language: 'javascript', stacked: true do |record|
    JSON.pretty_generate(record.body.as_json) if record.body.present?
  end

  field :webhook_request_jobs, as: :has_many
  # field :versions, as: :has_many, use_resource: ContractVersionResource, is_readonly: true
  # action ::Contracts::CreatePayment

  filter ::BaseStatusFilter, arguments: { model_class: WebhookRequest }
  actions [DeleteAction, WebhookRequests::RetryAction]
end
