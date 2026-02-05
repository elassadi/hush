class InsuranceResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting.with_options(show_uuid: :show)
  include Concerns::AccountField
  include Concerns::DateResourceSidebar

  self.model_class = ::Insurance

  self.title = :name
  self.includes = [:account]
  self.authorization_policy = SharedDataAccessPolicy

  field :company_name, as: :text

  with_options hide_on: [:index] do
    field :first_name, as: :text
    field :last_name, as: :text
    field :comunication, as: :heading, name: :heading_contact_channel

    field :email, as: :text
    field :phone_number, as: :text
    field :mobile_number, as: :text
  end
  field :addresses, as: :has_many
end
