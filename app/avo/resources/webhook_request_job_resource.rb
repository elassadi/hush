class WebhookRequestJobResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray:    %w[unknown],
    info:    %w[processing],
    success: %w[success],
    warning: %w[],
    danger:  %w[failure]
  }.freeze

  self.title = :id
  self.includes = [:webhook_request]

  field :id, as: :id
  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :webhook_request_event, as: :text
  field :webhook_request_type, as: :text

  field :webhook_request, as: :belongs_to
  field_date_time :updated_at, show_seconds: true

  field :result, theme: "eclipse", as: :code, language: 'javascript', stacked: true

  # field :versions, as: :has_many, use_resource: ContractVersionResource, is_readonly: true
  # filter ::Contracts::StatusFilter
  # action ::Contracts::CreatePayment

  filter ::BaseStatusFilter, arguments: { model_class: WebhookRequestJob }
end
