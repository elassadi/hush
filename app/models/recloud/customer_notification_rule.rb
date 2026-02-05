class CustomerNotificationRule < ApplicationRecord
  include AccountOwnable

  string_enum :status, %w[active disabled deleted], _default: :active
  string_enum :channel, %w[mail sms whatsup]

  store :metadata, accessors: %i[
    trigger_events
  ], coder: JSON

  belongs_to :setting
  belongs_to :template

  validate :validate_template_type

  private

  def validate_template_type
    return if template&.template_type.to_s == channel.to_s

    errors.add(:template, "Template type must be #{channel}")
  end
end
