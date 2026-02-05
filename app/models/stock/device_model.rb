class DeviceModel < ApplicationRecord
  include AccountOwnable
  MODEL_PREFIX = "dmo".freeze

  belongs_to :device_manufacturer
  belongs_to :device_model_category, optional: true

  has_many :device_colors, dependent: :destroy
  has_many :repair_sets, dependent: :destroy
  has_many :devices, dependent: :restrict_with_error
  has_one_attached :image
  validates :image, content_type: ["image/jpeg", "image/png"],
                    size: { less_than: 3.megabytes }

  string_enum :status, %w[active disabled deleted], _default: :active

  validates :name, presence: true
  # before_destroy :prevent_destroy, prepend: true

  def full_name
    [device_manufacturer.name, name].join(" ")
  end

  def as_json(_options = {})
    {
      id:,
      name:,
      image_path: gsm_path
    }
  end

  def gsm_path
    if image.present?
      ActiveStorage::Current.url_options = Rails.application.config.default_url_options
      return image.url
    end

    picture_id = gsm_id.presence || id

    if Rails.root.join("public/images/device_pictures/#{picture_id}.jpg").exist?
      return "/images/device_pictures/#{picture_id}.jpg"
    end

    "/images/default_product_image.gif"
  end

  # def prevent_destroy

  #   device_count = Device.where(device_model: self, account: account).count
  #   return if device_count.zero?

  #   #errors.add(:base, I18n.t('shared.messages.destroy_not_possible'))
  #   raise StandardError, I18n.t('shared.messages.destroy_not_possible_still_in_use', count: device_count)
  # end
end
