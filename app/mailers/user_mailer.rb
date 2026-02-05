class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: "admin@hush-haarentfernung.de", subject: 'Welcome to My Awesome Site')
  end

  def activation_email(account)
    @account = account
    mail(to: check_recipient_emails(@account.email), subject: t('mailer.user.activation_email.subject'))
  end
end
