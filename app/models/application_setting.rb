class ApplicationSetting < Setting
  class << self
    def customer_notification_for(trigger:, channel: nil)
      return unless Current.application_settings.notification_enabled

      Current.application_settings.customer_notification_rules.status_active.find do |rule|
        Array(trigger).any? { |trigger_name| rule.trigger_events.include?(trigger_name.to_s) } &&
          (channel.nil? || rule.channel.to_s == channel.to_s)
      end
    end
  end
end
