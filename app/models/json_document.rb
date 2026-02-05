# app/models/lead.rb
class JsonDocument < ApplicationRecord
  validates :metadata, presence: true
  belongs_to :jsonable, polymorphic: true
end
