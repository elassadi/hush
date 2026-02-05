class DeviceColor < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "dco".freeze

  belongs_to :device_model
  has_one :device_manufacturer, through: :device_model
  validates :name, presence: true
end
