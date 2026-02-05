class AdminMailer < ApplicationMailer
  def maintenance_job_mail(stats)
    @stats = stats
    mail(to: "mohamed.elassadi@gmail.com", subject: 'Maintenance Job done')
  end

  def sms_check_job_mail(stats)
    @stats = stats
    mail(to: "mohamed.elassadi@gmail.com", subject: 'SMS Check Job done')
  end

  def reminder_job_mail(stats)
    @stats = stats
    mail(to: "mohamed.elassadi@gmail.com", subject: 'Reminder Job done')
  end

  def new_account_mail(account)
    mail(
      to: 'mohamed.elassadi@gmail.com',
      subject: 'New Account Created',
      body: "A new account with the name #{account.email} has been created."
    )
  end
end
