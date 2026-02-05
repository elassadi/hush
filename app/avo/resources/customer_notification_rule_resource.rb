class CustomerNotificationRuleResource < ApplicationBaseResource
  STATUS_OPTIONS = {
    gray: %w[],
    info: %w[mail],
    success: %w[whatsup active],
    warning: %w[sms],
    danger: %w[disabled deleted]
  }.freeze

  self.title = :trigger_event
  self.includes = []
  self.authorization_policy = GlobalDataAccessPolicy
  self.model_class = CustomerNotificationRule
  self.translation_key = "activerecord.attributes.customer_notification_rule"

  # self.resolve_query_scope = lambda { |model_class:|

  #   locales_entries_array = I18n.t('activerecord.attributes.template.trigger_events').keys.map(&:to_s)
  #   case_statements = locales_entries_array.map.with_index(1) do |key, index|
  #     "WHEN '#{key}' THEN #{index}"
  #   end
  #   query = model_class.unscope(:order).reorder(Arel.sql(
  #     "JSON_EXTRACT(JSON_UNQUOTE(`metadata`), '$.trigger_events[0]') DESC "
  #   ))
  #   query
  # }

  field :setting, as: :belongs_to, readonly: lambda {
                                               record.persisted?
                                             }

  field :status, as: :status_badge, options: STATUS_OPTIONS

  field :channel, as: :status_badge, options: STATUS_OPTIONS

  field :status, as: :select, hide_on: %i[show index new],
                 options: lambda { |_args|
                            ::CustomerNotificationRule.human_enum_names(:status,
                                                                        reject: :deleted,
                                                                        translate: true).invert
                          }, display_with_value: true, include_blank: false

  field :trigger_events,
        name: "Trigger",
        as: :tags, enforce_suggestions: true,
        placeholder: I18n.t('shared.select_an_option'),
        suggestions:
          lambda {
            I18n.t('activerecord.attributes.template.trigger_events').sort_by { |s| s[1] }.map do |value, label|
              { label:, value: }
            end
          }

  field :channel, as: :select, hide_on: %i[show index],
                  options: lambda { |_args|
                             ::CustomerNotificationRule.human_enum_names(:channel,
                                                                         translate: false).invert
                           }, display_with_value: true, include_blank: true

  field :template, as: :belongs_to, in_line: :create,
                   attach_scope: lambda {
                                   next query.none unless @parent.channel

                                   query.where(template_type: @parent.channel).reorder(:name)
                                 }, visible: lambda { |resource:|
                                               resource.model.channel.present?
                                             }

  filter CustomerNotificationRules::TriggerEventFilter
  # TODO:  Bug with filter in application setting resource Edit view . filter button is reloading for some reason
end
