class AccountResource < ApplicationBaseResource
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[disabled free],
    info: %w[],
    success: %w[active basic customer],
    warning: %w[pending_verification advanced],
    danger: %w[deleted recloud]
  }.freeze

  self.title = :name
  # self.includes = [:addresses]

  field :uuid, as: :uuid
  field :status, as: :status_badge, options: STATUS_OPTIONS

  field :account_type, as: :status_badge, options: STATUS_OPTIONS
  field :plan, as: :status_badge, options: STATUS_OPTIONS
  field :plan, as: :select, hide_on: %i[show index],
               options: ->(_args) { ::Account.human_enum_names(:plan, translate: false).invert },
               display_with_value: true

  field :account_type, as: :select, hide_on: %i[show index],
                       options: ->(_args) { ::Account.human_enum_names(:account_type, translate: false).invert },
                       display_with_value: true

  field :legal_form, as: :select, hide_on: %i[show index],
                     options: ->(_args) { ::Account.human_enum_names(:legal_form, translate: false).invert },
                     display_with_value: true

  field :name, as: :text, help: I18n.t('helpers.account.name')

  field :first_name, as: :text, only_on: [:forms]
  field :last_name, as: :text, only_on: [:forms]

  with_options hide_on: [:index] do
    field :legal_form, as: :status_badge
    field :comunication, as: :heading, name: :heading_contact_channel
    field :email, as: :text
    field :phone, as: :text
    field :subdomain, as: :text
  end

  with_options only_on: [:show] do
    field :street, as: :text do |record|
      record.primary_address&.street
    end
    field :house_number, as: :text do |record|
      record.primary_address&.house_number
    end
    field :post_code, as: :text do |record|
      record.primary_address&.post_code
    end
    field :city, as: :text do |record|
      record.primary_address&.city
    end
  end

  field :email, as: :text, only_on: :index

  field_date_time :updated_at, only_on: :index

  field :addresses, as: :has_many
  field :users, as: :has_many

  # field :versions, as: :has_many, use_resource: ContractVersionResource, is_readonly: true
  # filter ::Contracts::StatusFilter
  actions [
    ::Accounts::ActivateAction,
    ::Accounts::DisableAction
  ]
end
