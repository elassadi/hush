class Activity < ApplicationRecord
  include AccountOwnable
  include UserOwnable
  AVAILABLE_ACTIONS = %i[].freeze

  string_enum :status, %w[active], _default: :active
  belongs_to :activityable, polymorphic: true
  store :metadata, accessors: %i[
    activity_name
    activity_data
  ], coder: JSON

  scope :notification_only, lambda {
    where(
      "JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.activity_name') =  'email_sent' " \
      "OR JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.activity_name') = 'sms_sent' "
    )
  }

  def _title
    "#{owner.name}  #{activity_name} #{triggering_event}"
  end

  def workflow_transition?
    activity_name == 'workflow_transition'
  end

  def email_sent?
    activity_name == 'email_sent'
  end

  def sms_sent?
    activity_name == 'sms_sent'
  end

  def title
    scope = "activerecord.attributes.activity.activity_names"
    I18n.t(activity_name, scope:, owner_name: owner.name.capitalize, triggering_event: i18n_triggering_event,
                          status_before: i18n_status_before, status_after: i18n_status_after)
  end

  def i18n_triggering_event
    key = "activerecord.attributes.issue.workflow_events.#{triggering_event}"
    translated = I18n.t(key) if I18n.exists?(key)
    key = if triggering_event.start_with?("issue_")
            "activerecord.attributes.customer_notification_rule.trigger_events.#{triggering_event}"
          else
            "activerecord.attributes.customer_notification_rule.trigger_events.issue_#{triggering_event}"
          end

    if !I18n.exists?(key) && !translated
      key = "activerecord.attributes.customer_notification_rule.trigger_events.#{triggering_event}"
    end

    translated || I18n.t(key)
  end

  def i18n_status_before
    return unless I18n.exists?("activerecord.attributes.issue.statuses.#{status_before}")

    I18n.t("activerecord.attributes.issue.statuses.#{status_before}")
  end

  def i18n_status_after
    return unless I18n.exists?("activerecord.attributes.issue.statuses.#{status_after}")

    I18n.t("activerecord.attributes.issue.statuses.#{status_after}")
  end

  # <%= activity.owner.name %> hat Folgendes aktualisiert: <span class="font-bold"><%= activity.activity_name %>

  def status_before
    activity_data['from']
  end

  def status_after
    activity_data['to']
  end

  def triggering_event
    activity_data['triggering_event']
  end

  def customer_notification_method
    {
      'workflow_transition' => '-',
      'email_sent' => 'mail',
      'sms_sent' => 'sms'
    }[activity_name]
  end
end
