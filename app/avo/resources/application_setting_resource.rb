class ApplicationSettingResource < ApplicationBaseResource
  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.#{to_s.underscore.gsub(/_resource/, '')}"
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

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

  field :heading, as: :heading_help, i18n_key: :heading_print_templates,
                  path: "/vorlagen/print_templates"

  def self.get_template_name(value)
    Template.find_by(id: value)&.name
  end

  def self.template_options
    Template.by_account.template_type_print.pluck(:name, :id)
  end

  field :kva_print_template, as: :status_badge, format_using: lambda { |value|
                                                                ApplicationSettingResource.get_template_name(value)
                                                              }
  field :kva_print_template, as: :select,
                             options: lambda { |_args|
                                        ApplicationSettingResource.template_options
                                      }, display_with_value: true, include_blank: true, hide_on: %i[show index]

  field :order_print_template, as: :status_badge,
                               format_using: lambda { |value|
                                               ApplicationSettingResource.get_template_name(value)
                                             }
  field :order_print_template, as: :select,
                               options: lambda { |_args|
                                          ApplicationSettingResource.template_options
                                        }, display_with_value: true, include_blank: true, hide_on: %i[show index]

  field :invoice_print_template, as: :status_badge,
                                 format_using: lambda { |value|
                                                 ApplicationSettingResource.get_template_name(value)
                                               }
  field :invoice_print_template, as: :select,
                                 options: lambda { |_args|
                                            ApplicationSettingResource.template_options
                                          }, display_with_value: true, include_blank: true, hide_on: %i[show index]

  field :canceld_invoice_print_template, as: :status_badge,
                                         format_using: lambda { |value|
                                                         ApplicationSettingResource.get_template_name(value)
                                                       }
  field :canceld_invoice_print_template,
        as: :select,
        options: lambda { |_args|
          ApplicationSettingResource.template_options
        }, display_with_value: true, include_blank: true, hide_on: %i[show index]

  field :repair_report_print_template, as: :status_badge,
                                       format_using: lambda { |value|
                                                       ApplicationSettingResource.get_template_name(value)
                                                     }
  field :repair_report_print_template,
        as: :select,
        options: lambda { |_args|
                   ApplicationSettingResource.template_options
                 }, display_with_value: true, include_blank: true, hide_on: %i[show index]

  field :heading, as: :heading_help, i18n_key: :heading_notification_settings,
                  path: "/application_settings/notification"
  field :notification_enabled, as: :boolean, default: true

  field :heading, as: :heading_help, i18n_key: :heading_mail_settings,
                  path: "/application_settings/mail"

  field :default_mail_from, as: :text, hide_on: %i[index]
  field :default_mail_reply_to, as: :text, hide_on: %i[index]
  field :default_calendar_mail, as: :text, hide_on: %i[index],
                                help: I18n.t('helpers.setting.default_calendar_mail')
  field :mail_external_smtp_enabled,
        as: :boolean, hide_on: %i[index], default: false, feature_required: :external_smtp

  field :mail_smtp_address, as: :text, hide_on: %i[show index],
                            visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }
  field :mail_smtp_port, as: :text, hide_on: %i[show index], default: 587,
                         visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }
  field :mail_domain, as: :text, hide_on: %i[show index],
                      visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }

  field :mail_authentication, as: :select, options: %w[login plain], hide_on: %i[show index], default: "login",
                              visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }
  field :mail_username, as: :text, hide_on: %i[show index],
                        visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }
  field :mail_password, as: :text, hide_on: %i[show index],
                        visible: ->(resource:) { resource.model.mail_external_smtp_enabled? }

  field :heading, as: :heading_help, i18n_key: :heading_sms_settings,
                  path: "/application_settings/sms"
  field :sms_enabled, as: :boolean, hide_on: %i[index], default: false,
                      feature_required: :sms_notifications

  field :sms_provider, as: :select, options: %w[sms77 recloud],
                       hide_on: %i[show index], display_with_value: true,
                       placeholder: I18n.t("avo.choose_an_option"), include_blank: true,
                       visible: ->(resource:) { resource.model.sms_enabled? }

  field :sms_username, as: :text, hide_on: %i[show index],
                       visible: ->(resource:) { resource.model.sms_enabled? && resource.model.sms_provider == "sms77" }
  field :sms_password, as: :text, hide_on: %i[show index],
                       help: I18n.t('helpers.setting.sms_password'),
                       visible: ->(resource:) { resource.model.sms_enabled? && resource.model.sms_provider == "sms77" }

  field :customer_notification_rules, as: :has_many, show_on: :edit,
                                      use_resource: CustomerNotificationRuleResource, modal_create: true
end
