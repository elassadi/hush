class IssueMailer < ApplicationMailer
  def call(issue:, template:, documents: [])
    @issue    = issue
    @account  = @issue.account
    @customer = @issue.customer
    @template = template

    Array(documents).each do |document|
      attach_document(document)
    end
    parse_template_data
    send_email
  end

  private

  def attach_document(document)
    blob = document.file.blob
    attachments[blob.filename.to_s] = {
      mime_type: blob.content_type,
      content: blob.download
    }
  end

  def parse_template_data
    @data = @template.prepare_data(@issue)

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
      html: ActionController::Base.helpers.sanitize(faraday_result.body["body"]),
      plain: ActionController::Base.helpers.sanitize(faraday_result.body["body"], tags: [])
    }
  end
end
