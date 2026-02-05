class SmsWebhookRequest < WebhookRequest
  delegate :client, to: :payment

  before_create :register_event
  before_create :detect_and_save_sms_uuid

  SMS_EVENTS = [
    "sms:received",
    "sms:sent",
    "sms:failed",
    "sms:delivered"
  ].freeze

  def register_event
    return unless event_type_registered?

    self.event = event_type.downcase
  end

  def event_type_registered?
    SMS_EVENTS.include?(event_type)
  end

  def detect_and_save_sms_uuid
    self.event_uuid = body.dig("payload", "messageId")
  end

  def verified?
    true
  end

  def event_type
    body["event"]
  end

  def event_type_class
    event_type_class_name.constantize
  end

  def event_type_class_name
    "::Sms::Events::#{event_type.downcase.tr(':', '_').camelize}"
  end

  def incoming_sms_id
    return unless event_type == "sms:received"

    body["id"]
  end

  def incoming_sms_message
    return unless event_type == "sms:received"

    body.dig("payload", "message")
  end

  def incoming_sms_phone_number
    return unless event_type == "sms:received"

    body.dig("payload", "phoneNumber")
  end
end
