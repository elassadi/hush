class ImportMailer < ApplicationMailer
  def imported_email(document:, user:)
    @user = user
    @document = document
    mail(to: check_recipient_emails(@user.email), subject: t('mailer.user.imported_email.subject'))
  end
end
