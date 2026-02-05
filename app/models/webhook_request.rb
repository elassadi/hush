class WebhookRequest < ApplicationRecord
  string_enum :status, %w[pending retry success failure skipped forbiden], _default: :pending
  validates :status, inclusion: { in: statuses }

  has_many :webhook_request_jobs, dependent: :destroy

  # belongs_to :payment, foreign_key: :payment_uuid, primary_key: :uuid, optional: true
  # has_one :contract, through: :payment
end
