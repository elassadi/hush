class DeviceModelCategory < ApplicationRecord
  include AccountOwnable

  MODEL_PREFIX = "dmc".freeze
  has_many :device_models

  has_one_attached :image
  validates :image, content_type: ["image/jpeg", "image/png"],
                    size: { less_than: 3.megabytes }

  string_enum :status, %w[active disabled deleted], _default: :active

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: %i[account_id name] }

  def as_json(_options = {})
    {
      id:,
      name:,
      image_path: gsm_path
    }
  end

  def image_path
    if image.present?
      ActiveStorage::Current.url_options = Rails.application.config.default_url_options
      return image.url
    end

    "/images/default_product_image.gif"
  end
end
