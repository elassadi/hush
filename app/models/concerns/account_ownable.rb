module AccountOwnable
  extend ActiveSupport::Concern

  included do
    default_scope { includes(:account) }
    belongs_to :account, optional: true
    before_validation :assign_account
  end

  private

  def assign_account
    return unless respond_to?(:account_id)
    return if account_id.present?
    return if Current.user.blank?

    self.account_id = Current.user.current_account.id
  end
end
