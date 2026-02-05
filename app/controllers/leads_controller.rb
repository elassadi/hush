class LeadsController < ApplicationController
  def new
    @lead = Lead.new
  end

  def create
    @lead = Lead.new(lead_params)

    return render 'static_pages/contact' unless verify_recaptcha(model: @lead)

    if @lead.save
      LeadMailer.new_lead(@lead).deliver_now
      redirect_to leads_thanks_path, notice: 'Ihre Anfrage wurde erfolgreich gesendet.'
    else
      render 'static_pages/contact'
    end
  end

  def thank_you; end

  private

  def lead_params
    params.require(:lead).permit(:email, :company_name, :phone_number, :message)
  end
end
