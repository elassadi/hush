class TemplateResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: false)
  include Concerns::AccountField

  STATUS_OPTIONS = {
    gray: %w[text sms],
    info: %w[],
    success: %w[],
    warning: %w[mail],
    danger: %w[print]
  }.freeze

  self.title = :name
  self.includes = []
  self.authorization_policy = ::GlobalDataAccessPolicy
  self.stimulus_controllers = ["template-resource"]

  self.hide_from_global_search = true
  self.search_query = lambda {
    scope.ransack(name_matches: "%#{params[:q]}%", m: "or").result(distinct: false)
  }
  self.resolve_query_scope = lambda { |model_class:|
    model_class.order(created_at: :desc)
  }

  field :template_type, as: :status_badge, options: STATUS_OPTIONS
  field :template_type, as: :select, hide_on: %i[index show],
                        options: ->(_args) { ::Template.human_enum_names(:template_type).invert },
                        display_with_value: true, include_blank: true,
                        html: {
                          edit: { input: { data: { action: "template-resource#onTemplateTypeSelectChange" } } },
                          new: { input: { data: { action: "template-resource#onTemplateTypeSelectChange" } } }
                        },
                        readonly: -> { record&.persisted? && !params[:via_cloned_id] }

  field :name, as: :text, readonly: -> { record&.protected? && !params[:via_cloned_id] }

  field :customer_notification_rule_triggers,
        as: :tags,
        only_on: %i[index],
        suggestions: lambda {
                       I18n.t('activerecord.attributes.template.trigger_events').map do |value, label|
                         { label:, value: }
                       end
                     }
  field_date_time :updated_at, only_on: :show, show_seconds: true

  field :subject, as: :text, hide_on: %i[index], visible: lambda { |resource:|
    resource.model.template_type_mail?
  }

  field :tags, as: :tags, close_on_select: true, hide_on: %i[index],
               suggestions: lambda {
                              next [{}] unless record.template_type_repair_report?

                              key = "activerecord.attributes.template.tags_values.#{record.template_type}"
                              next [{}] unless I18n.exists?(key)

                              I18n.t(key).map do |tag|
                                value, label = tag
                                { label:, value: }
                              end
                            }
  # field :body, always_show: true, as: :trix, stacked: true, show_on: :all, attachment_key: :trix_attachments
  field :html_body, always_show: true,
                    as: :textarea, stacked: true, html: {
                      edit: { input: { classes: "tinymce " } },
                      wrapper: { classes: " hidden" }
                    }, only_on: :forms

  field :text_body, always_show: true, as: :textarea, stacked: true, only_on: :forms,
                    html: { edit: { wrapper: { classes: " hidden" } } }
  field :heading, as: :heading_help, i18n_key: :heading_variable_list, path: '/documents/template.html'

  field :body, as: :text, stacked: true,
               as_html: true, only_on: :show, format_using: ->(_value) { resource.model.preview_content }

  field :customer_notification_rules, as: :has_many

  actions(::CloneAction)

  filter Templates::TypeFilter
  filter Templates::InUseFilter
end
