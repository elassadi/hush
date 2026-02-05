class ApiToken < ApplicationRecord
  include AccountOwnable
  has_secure_token :token, length: 36
  string_enum :status, %w[active deleted], _default: :active
  belongs_to :user
end
