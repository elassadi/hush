class AddressResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[draft],
    info: %w[],
    success: %w[active],
    warning: %w[archived],
    danger: %w[]
  }.freeze

  self.title = :street
  self.model_class = ::Address
  self.includes = []

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :status, as: :status_badge, options: STATUS_OPTIONS
  field :addressable, as: :belongs_to,
                      polymorphic_as: :addressable, searchable: true,
                      types: [::Contact, ::Supplier, ::Customer, ::Merchant, ::Account, ::ContactRecord]
  field :street, as: :text
  field :house_number, as: :text
  field :post_code, as: :text
  field :city, as: :text
  # field :country, as: :country, index_text_align: :left, only_on: :forms

  ADDRESSES_ACTIONS = [
    ::Addresses::ActivateAction
  ].freeze

  # actions ADDRESSES_ACTIONS
  filter ::BaseStatusFilter, arguments: { model_class: Address }
end
