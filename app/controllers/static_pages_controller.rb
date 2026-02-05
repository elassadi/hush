class StaticPagesController < ApplicationController
  def contact
    @lead = Lead.new
    @lead.email = params[:email] if params[:email].present?
    return if params[:subject].blank?

    @lead.message = I18n.t('activerecord.attributes.leads.ref_customer.message') if params[:subject] == 'ref_customer'

    return unless params[:subject] == 'advanced'

    @lead.message = I18n.t('activerecord.attributes.leads.advanced.message')
  end
end
