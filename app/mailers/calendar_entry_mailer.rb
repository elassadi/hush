class CalendarEntryMailer < ApplicationMailer
  def call(calendar_entry:, template:, ics_document: nil)
    @calendar_entry = calendar_entry
    @account  = @calendar_entry.account
    @customer = @calendar_entry.customer
    @template = template
    @ics_document = ics_document

    attach_ics_document if ics_document.present?
    parse_template_data
    send_email
  end

  private

  def attach_ics_document
    blob = @ics_document.file.blob
    attachments[blob.filename.to_s] = {
      mime_type: blob.content_type,
      content: blob.download
    }
  end

  def parse_template_data
    @data = @template.prepare_data(@calendar_entry)

    @parsed_content = parse_template(template: @template, data: @data)
  end

  def subject
    @template.subject || @template.name
  end

  def send_email
    mail(to: check_recipient_emails(@customer.email),
         from:,
         reply_to:,
         subject:) do |format|
      format.html { render html: @parsed_content[:html] }
      format.text { render plain: @parsed_content[:plain] }
    end
  end

  def parse_template(template:, data:)
    dry_result = ::Templates::ParseOperation.call(template:, data:)

    raise "Could not run parse call for template: #{template.name}" unless dry_result.success?

    faraday_result = dry_result.success
    raise "Could parse call for template: #{template.name}" unless faraday_result.success?

    {
      html: faraday_result.body["body"].html_safe, # rubocop:todo Rails/OutputSafety
      plain: ActionController::Base.helpers.sanitize(faraday_result.body["body"], tags: [])
    }
  end
end
