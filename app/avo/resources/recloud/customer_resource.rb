class CustomerResource < ApplicationBaseResource
  include Concerns::SequenceResourceSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar.with_fields(date_fields: %i(created_at updated_at))

  STATUS_OPTIONS = {
    gray: %w[disabled none],
    info: %w[],
    success: %w[active],
    warning: %w[company],
    danger: %w[deleted]
  }.freeze

  self.authorization_policy = ::MerchantDataAccessPolicy
  self.includes = [:merchant]
  self.stimulus_controllers = "create-issue-action"
  self.show_controls = lambda {
    back_button
    delete_button
    link_to "+ #{I18n.t('activerecord.attributes.issue.new_issue')}",
            # "/resources/issues/new?via_relation=customer&via_relation_class=Customer&via_resource_id=#{params[:id]}",
            "/resources/issues/new?via_customer_id=#{params[:id]}",
            style: :primary, color: :primary
    edit_button
    actions_list
  }

  self.search_query = lambda {
    ResourceHelpers::SearchEngine.call(
      search_query: params[:q], global: params[:global].to_boolean,
      scope: scope.status_active,
      model: :customer
    ).success
  }
  self.search_query_help = I18n.t("activerecord.attributes.customer.search_query_help")

  field :status, as: :status_badge, options: STATUS_OPTIONS, only_on: %i[show]

  field :customer_name, as: :text, hide_on: :all, as_label: true do |model|
    "#{::Customer.human_enum_name(:salutation, model.salutation)} #{model.title}"
  end

  field :search_customer_description, as: :text, hide_on: :all, as_description: true do |model|
    String(model.primary_address&.one_liner).truncate 130
    # rescue
    #  ""
  end

  field :salutation, as: :select, hide_on: %i[show index],
                     options: ->(_args) { ::Customer.human_enum_names(:salutation).invert }, display_with_value: true,
                     default: "female"

  field :salutation, as: :status_badge, hide_on: [:index], options: STATUS_OPTIONS
  field :name, as: :text, link_to_resource: true, hide_on: [:forms], visible: lambda { |resource:|
    !resource.model.salutation_company?
  }

  field :company_name, as: :text, visible: lambda { |resource:|
    resource.model.salutation_company?
  }

  field :first_name, as: :text, only_on: [:forms]
  # html: { edit: { input: { data: { action: "create-issue-action#onTextChange" } } } }
  field :last_name, as: :text, only_on: [:forms], help: ""

  # with_options only_on: %i[new edit] do
  #   field :heading_address, as: :heading
  #   field :street, as: :text
  #   field :house_number, as: :text
  #   field :post_code, as: :text
  #   field :city, as: :text
  # end

  with_options hide_on: [:index] do
    field :heading_contact_channel, as: :heading

    field :email, as: :text, required: false, help: "If not provided, will be generated from mobile number"

    field :mobile_number, as: :number, required: true
    # field :phone_number, as: :number
  end

  with_options only_on: [:show] do
    field :heading_address, as: :heading
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
  field :mobile_number, as: :text, only_on: :index
  field_date_time :updated_at, only_on: :index

  field :addresses, as: :has_many, modal_create: true
  field :issues, as: :has_many
  field :devices, as: :has_many
  field :comments, as: :has_many, modal_create: true

  # field :versions, as: :has_many, use_resource: CustomerVersionResource, is_readonly: true

  filter ::BaseStatusFilter, arguments: { model_class: Customer }
  filter ::Customers::NameFilter
end
