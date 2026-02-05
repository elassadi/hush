class WebhookRequestJob < ApplicationRecord
  string_enum :status, %w[unknown processing success failure], _default: :processing
  belongs_to :webhook_request

  delegate :event, to: :webhook_request, prefix: true, allow_nil: true
  delegate :type, to: :webhook_request, prefix: true, allow_nil: true
end
