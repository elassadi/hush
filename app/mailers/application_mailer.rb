# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  attr_reader :account

  DEFAULT_MAIL_FROM = 'no-reply@hush-haarentfernung.de'
  default from: DEFAULT_MAIL_FROM
  layout 'mailer'
  prepend_view_path "app/views/mailer"

  DEVELOPMENT_RECIPIENT_EMAILS = "mohamed.elassadi@gmail.com"
  DEFAULT_BCC_EMAIL = "mohamed.elassadi+bcc@gmail.com"

  def check_recipient_emails(emails)
    return emails if Rails.env.production? || Rails.env.test?

    DEVELOPMENT_RECIPIENT_EMAILS
  end

  def notification_mail(message)
    mail(to: ["admin@hush-haarentfernung.de"], subject: "Event triggered  at: #{Rails.env}") do |format|
      format.html { "Event triggered #{message}" }
      format.text { "Event triggered #{message}" }
    end
  end

  def from
    account.application_settings.default_mail_from.presence || account.merchant.email || DEFAULT_MAIL_FROM
  end

  def reply_to
    account.application_settings.default_mail_reply_to || from
  end

  def _mail(...)
    configure_smtp_settings
    super(...)
  end

  def mail(headers = {}, &)
    headers[:bcc] = Array(headers[:bcc]) + [DEFAULT_BCC_EMAIL]
    configure_smtp_settings
    super(headers, &)
  end

  private

  def configure_smtp_settings
    if account&.application_settings&.mail_external_smtp_enabled?
      merge_application_smtp_settings
    else
      merge_default_smtp_settings
    end
  end

  def merge_default_smtp_settings
    smtp_settings.merge!(Rails.application.config.default_smtp_settings)
  end

  def merge_application_smtp_settings
    application_settings = account.application_settings
    customer_settings = {
      address: application_settings.mail_smtp_address,
      port: application_settings.mail_smtp_port,
      domain: application_settings.mail_domain,
      user_name: application_settings.mail_username,
      password: application_settings.mail_password,
      authentication: application_settings.mail_authentication.to_sym
    }
    smtp_settings.merge!(customer_settings)
  end
end
