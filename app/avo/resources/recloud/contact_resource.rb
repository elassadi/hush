class ContactResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  STATUS_OPTIONS = {
    gray: %w[unknown],
    info: %w[],
    success: %w[paid],
    warning: %w[refunded],
    danger: %w[unknown]
  }.freeze

  self.model_class = ::Contact

  self.title = :name
  self.includes = [:account]

  self.hide_from_global_search = true
  self.search_query = lambda {
    scope.ransack(first_name_matches: "%#{params[:q]}%",
                  last_name_matches: "%#{params[:q]}%",
                  email_matches: "%#{params[:q]}%",
                  m: "or").result(distinct: false)
  }

  field :company_name, as: :text

  with_options hide_on: [:index] do
    field :first_name, as: :text
    field :last_name, as: :text
    field :comunication, as: :heading, name: :heading_contact_channel

    field :email, as: :text
    field :phone_number, as: :text
    field :mobile_number, as: :text
  end

  # with_options only_on: [:show] do
  #   field :address, as: :heading, name: :heading_address
  #   field :street, as: :text do |record|
  #     record.primary_address&.street
  #   end
  #   field :house_number, as: :text do |record|
  #     record.primary_address&.house_number
  #   end
  #   field :post_code, as: :text do |record|
  #     record.primary_address&.post_code
  #   end
  #   field :city, as: :text do |record|
  #     record.primary_address&.city
  #   end
  #   field :country, as: :country do |record|
  #     record.primary_address&.country
  #   end
  # end

  # field :primary_address, as: :has_one
  field :addresses, as: :has_many
  field :comments, as: :has_many
end
