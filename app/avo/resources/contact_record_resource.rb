class ContactRecordResource < ApplicationBaseResource
  include Concerns::ResourcesDefaultSetting
  self.model_class = ContactRecord

  field :id, as: :id
end
