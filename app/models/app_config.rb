class AppConfig < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  GLOBAL_TAX = 19.0
  class << self
    def [](k)
      (record = AppConfig.find_by(key: k)) && record.value
    end
  end
end
