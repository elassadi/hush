class SupplierResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.model_class = ::Supplier

  self.title = :company_name
  self.includes = [:account]

  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :status, as: :select, hide_on: %i[show index],
                 options: lambda { |_args|
                            ::Supplier.human_enum_names(:status, translate: true, reject: :deleted).invert
                          }, display_with_value: true, include_blank: false

  field :company_name, as: :text

  with_options hide_on: [:index] do
    field :first_name, as: :text, nullable: true
    field :last_name, as: :text, nullable: true
    field :comunication, as: :heading, name: :heading_contact_channel

    field :email, as: :text, nullable: true
    field :phone_number, as: :text, nullable: true
    field :mobile_number, as: :text, nullable: true
    field :stock_api_url, as: :text, nullable: true
    field :daily_sync, as: :boolean
  end

  field :documents, as: :has_many
  field :addresses, as: :has_many
end
