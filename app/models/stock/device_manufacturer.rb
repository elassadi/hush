class DeviceManufacturer < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "dma".freeze

  has_many :device_models, inverse_of: :device_manufacturer, dependent: :destroy
  has_many :repair_sets, through: :device_models

  validates :name, presence: true, uniqueness: { scope: %i[account_id] }
end
