class BookingController < ApplicationController
  before_action :setup_current_account!

  def show
    redirect_to "/booking_not_enabled.html" and return unless booking_enabled?

    @booking_data = {
      accountName: @account.name,
      accountUuid: @account.uuid,
      token: @account.public_token,
      withSubdomain: account_by_subdomain ? request.subdomain : nil
    }
  end

  def thanks; end

  def setup_current_account!
    @account = account_by_uuid || account_by_subdomain
    raise ActiveRecord::RecordNotFound unless @account
  end

  private

  def booking_enabled?
    true
    # @account.global_settings.booking_enabled?
  end

  def account_by_subdomain
    @account_by_subdomain ||= request.subdomain.present? && Account.find_by(subdomain: request.subdomain)
  end

  def account_by_uuid
    uuid = params.permit(:id)[:id]
    return if uuid.blank?

    Account.find_by(uuid:)
  end
end
