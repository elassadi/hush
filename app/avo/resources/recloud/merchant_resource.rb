class MerchantResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  AFFILIATE_TYPES = {
    gray: %w[partner],
    info: %w[],
    success: %w[],
    warning: %w[branch],
    danger: %w[master]
  }.freeze

  self.model_class = ::Merchant

  self.title = :title
  self.includes = [:account]
  self.stimulus_controllers = "merchant-resource"
  self.authorization_policy = GlobalDataAccessPolicy

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :affiliate_type, as: :status_badge, options: AFFILIATE_TYPES
  field :affiliate_type,
        as: :select,
        options: [%w[Filiale branch], %w[Partner partner]],
        display_with_value: true, hide_on: %i[show index],
        visible: lambda { |resource:|
          !resource.record&.master?
        }

  field :company_name, as: :text
  field :branch_name, as: :text, help: I18n.t('helpers.merchant.branch_name')

  with_options hide_on: [:index] do
    field :logo, as: :file, is_image: true, as_avatar: :rounded,
                 height: "80px", accept: "image/*",
                 link_to_resource: true, hide_on: %i[new], full_width: false

    field :first_name, as: :text
    field :last_name, as: :text
    field :heading_comunication_channel, as: :heading
    field :email, as: :text
    field :accounting_email, as: :text
    field :phone_number, as: :text
    field :mobile_number, as: :text
    field :heading_bank_account, as: :heading
    field :bank_name, as: :text
    field :iban, as: :text
    field :bank_account_owner, as: :text
    field :heading_legal_information, as: :heading
    field :ceo_name, as: :text
    field :hrb_number, as: :text
    field :court_in_charge, as: :text
    field :tax_number, as: :text
  end

  field :business_hours, as: :has_many, use_resource: BusinessHourResource, modal_create: true
  field :addresses, as: :has_many, modal_create: true
  field :users, as: :has_many
end
