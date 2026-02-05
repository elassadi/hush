class CorePolicy < ApplicationRecord
  belongs_to :role
  has_many :permissions, dependent: :restrict_with_error
end
