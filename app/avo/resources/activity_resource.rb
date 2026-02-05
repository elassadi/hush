class ActivityResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray: %w[draft awaiting_approval open -],
    info: %w[in_progress awaiting_device awaiting_parts ready_to_repair repairing repairing_successfull
             repairing_unsuccessfull mail],
    success: %w[done completed repairing_successfull whatsup],
    warning: %w[sms],
    danger: %w[canceld repairing_unsuccessfull]
  }.freeze

  STATUS_OPTIONS_ = {
    gray: %w[],
    info: %w[],
    success: %w[],
    warning: %w[],
    danger: %w[mail]
  }.freeze

  self.title = :i18n_triggering_event
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  self.includes = [:owner]

  field :owner, as: :belongs_to, only_on: %i[show index]

  field :triggering_event, as: :text, only_on: %i[show index], format_using:  lambda { |value|
    key = "activerecord.attributes.issue.workflow_events.#{value}"
    return I18n.t(key) if I18n.exists?(key)

    key = "activerecord.attributes.customer_notification_rule.trigger_events.#{value}"
    return I18n.t(key) if I18n.exists?(key)

    I18n.t("activerecord.attributes.customer_notification_rule.trigger_events.issue_#{value}")
  }

  field :status_before, as: :status_badge, options: STATUS_OPTIONS, shorten: false,
                        i18n_scope: "activerecord.attributes.issue", i18n_field_id: "status"
  field :status_after, as: :status_badge, options: STATUS_OPTIONS, shorten: false,
                       i18n_scope: "activerecord.attributes.issue", i18n_field_id: "status"

  field :customer_notification_method, as: :status_badge, options: STATUS_OPTIONS, shorten: false
  field_date_time :created_at
end
