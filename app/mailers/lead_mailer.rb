class LeadMailer < ApplicationMailer
  def new_lead(lead)
    @lead = lead
    mail(to: "mohamed.elassadi@gmail.com", subject: 'Contact from homepage')
  end
end
