class JsonDocumentResource < ApplicationBaseResource
  include Concerns::AccountField

  self.authorization_policy = GlobalDataAccessPolicy
  self.translation_key = "activerecord.attributes.json_document"

  self.title = :id
  self.includes = []

  field :id, as: :id
end
