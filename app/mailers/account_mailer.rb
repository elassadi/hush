class AccountMailer < ApplicationMailer
  def new_calendar_entry(calendar_entry:)
    @calendar_entry = calendar_entry
    @account  = @calendar_entry.account
    @customer = @calendar_entry.customer

    @jump_to_url = jump_to_url

    send_email("Neue Terminanfrage")
  end

  private

  def jump_to_url
    [
      Rails.application.config.default_url_options[:protocol],
      "://",
      Rails.application.config.default_url_options[:host],
      "/calendar_tool?calendar_entry_id=#{@calendar_entry.id}"
    ].join
  end

  def send_email(subject)
    mail(
      to: check_recipient_emails(@account.application_settings.default_calendar_mail.presence || @account.email),
      from:,
      reply_to:,
      subject:
    )
  end
end
