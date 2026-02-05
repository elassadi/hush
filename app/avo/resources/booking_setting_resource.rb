class BookingSettingResource < ApplicationBaseResource
  include Concerns::AccountField
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: false)

  STATUS_OPTIONS = {
    gray: %w[disabled],
    info: %w[],
    success: %w[active],
    warning: %w[pending_verification],
    danger: %w[deleted]
  }.freeze

  self.show_controls = lambda {
    edit_button
  }

  self.title = :title
  self.resource_default_view = :edit

  field :heading, as: :heading_help, i18n_key: :heading_booking_settings,
                  path: "/settings/booking"

  field :booking_enabled, as: :boolean, default: true, help: I18n.t('helpers.setting.booking_enabled')
  field :booking_slot_duration, as: :number, default: 90, help: I18n.t('helpers.setting.booking_slot_duration')
  field :booking_slot_search_mode,
        as: :select,
        options: lambda { |_args|
                   I18n.t("activerecord.attributes.booking_setting.slot_search_modes").reduce(&:merge).invert
                 },
        display_with_value: true,
        help: I18n.t('helpers.setting.booking_slot_search_mode')

  field :booking_confirmed_slots_capacity, as: :number, step: 1,
                                           help: I18n.t('helpers.setting.booking_confirmed_slots_capacity')
  field :booking_unconfirmed_slots_capacity, as: :number, step: 1,
                                             help: I18n.t('helpers.setting.booking_unconfirmed_slots_capacity')

  field :heading, as: :heading_help, i18n_key: :heading_booking_lead_time
  field :booking_lead_time_min, as: :number, help: I18n.t('helpers.setting.booking_lead_time_min')
  field :booking_lead_time_max, as: :number, help: I18n.t('helpers.setting.booking_lead_time_max')

  field :heading, as: :heading_help, i18n_key: :heading_booking_notification,
                  path: "/settings/booking"

  field :booking_reminder_enabled, as: :boolean, default: true, help: I18n.t('helpers.setting.booking_reminder_enabled')

  field :booking_reminder_frequency,
        as: :tags, enforce_suggestions: true,
        placeholder: I18n.t('shared.select_an_option'),
        help: I18n.t('helpers.setting.booking_reminder_frequency'),
        suggestions:
          lambda {
            sorted_frequencies = I18n.t('activerecord.attributes.booking_setting.booking_reminder_frequencies')
                                     .sort_by do |s|
              s[1]
            end
            sorted_frequencies.map { |value, label| { label:, value: } }
          }
end
