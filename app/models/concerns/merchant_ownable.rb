module MerchantOwnable
  extend ActiveSupport::Concern

  included do
    belongs_to :merchant
    before_validation :assign_merchant
  end

  def assign_merchant
    return unless respond_to?(:merchant_id)
    return if merchant_id.present?
    return if Current.user.blank?

    self.merchant = Current.user.merchant
  end
end
