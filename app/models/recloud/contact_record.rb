class ContactRecord < ApplicationRecord
  include AccountOwnable

  encrypts :iban

  RECENT_LIMIT = 10

  string_enum :status, %w[active disabled deleted], _default: :active
  validates :phone_number, :mobile_number, numericality: { only_integer: true },
                                           allow_blank: true
  validates :post_code, numericality: { only_integer: true }, allow_blank: true
  store :metadata, accessors: %i[stock_api_url daily_sync], coder: JSON
  def name
    [first_name, last_name].join(" ")
  end

  def telephone
    mobile_number || phone_number
  end

  def street_only
    return if street.blank?

    result = street.match(Constants::STREET_NUMBER_REGEX)
    result && result[1]
  end

  def street_no
    return if street.blank?

    result = street.match(Constants::STREET_NUMBER_REGEX)
    result && result[2]
  end

  class << self
    def to_select
      limit(1000).pluck(:company_name, :id)
    end

    def recent
      order(id: :desc).limit(RECENT_LIMIT)
    end
  end
end
