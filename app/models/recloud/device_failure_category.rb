class DeviceFailureCategory < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "dfc".freeze

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: %i[account_id name] }

  class << self
    def cached_suggestions
      Rails.cache.fetch("suggestions_#{Current.account_id}_device_failure_category", expires_in: 30.minutes) do
        DeviceFailureCategory.by_account.pluck(:name).map do |tag|
          { label: tag, value: tag }
        end
      end
    end
  end
end
