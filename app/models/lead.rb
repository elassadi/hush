# app/models/lead.rb
class Lead < ApplicationRecord
  validates :email, presence: true
  validates :company_name, presence: true
  validates :message, presence: true
end
