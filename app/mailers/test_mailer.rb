class TestMailer < ApplicationMailer
  default from: 'admin@hush-haarentfernung.de'

  def test_email(account: nil, to: nil)
    @account = account if account.present?
    mail(
      to: to || 'mohamed.elassadi@gmail.com',
      subject: 'Test Email',
      body: 'This is a test email sent from Rails!'
    )
  end
end
