class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session
  attribute :request_id, :user_agent, :ip_address, :stop, :session

  delegate :account, to: :user
  delegate :application_settings, :booking_settings, to: :account

  def account_id
    @account_id ||= account.id
  end
end
