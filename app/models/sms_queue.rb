class SmsQueue < ApplicationRecord
  MODEL_PREFIX = "SMS".freeze
  include AccountOwnable
  belongs_to :issue, optional: true

  string_enum :status, %w[pending queued sent delivered received failed], _default: :queued

  def message_teaser
    return if message.blank?

    message[0..63] << "..."
  end
end
