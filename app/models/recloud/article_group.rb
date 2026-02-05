class ArticleGroup < ApplicationRecord
  MODEL_PREFIX = "arg".freeze
  include AccountOwnable
  validates :name, presence: true, uniqueness: { scope: %i[account_id], case_sensitive: false }
end
