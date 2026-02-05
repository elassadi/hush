class GlobalSettingResource < ApplicationBaseResource
  self.authorization_policy = GlobalDataAccessPolicy
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
    actions_list
    edit_button
  }
  self.title = :title
  self.model_class = ::Setting
  self.stimulus_controllers = ["global-setting-resource"]

  field :category, as: :status_badge, options: STATUS_OPTIONS
  field :tax, as: :text

  field :document_footer, always_show: true, as: :textarea, stacked: true, html: {
    edit: { input: { classes: "tinymce " } }
  }, only_on: :forms, feature_required: :document_footer

  field :document_footer, as: :text, stacked: true, as_html: true, only_on: :show,
                          format_using: ->(value) { "<pre>#{value}</pre>" }

  field :print_detailed_issue_entries, as: :boolean, stacked: true, html: {
    edit: { wrapper: { classes: "whitespace-nowrap" } },
    show: { wrapper: { classes: "whitespace-nowrap" } }
  }

  field :sequences, as: :has_many, modal_create: true, show_on: :edit
end
