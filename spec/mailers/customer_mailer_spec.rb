RSpec.describe IssueMailer, type: :mailer do
  include_context "setup system user"
  include_context "setup demo account and user"
  let!(:global_settings) { create(:global_setting) }
  let!(:application_settings) { create(:application_setting) }
  let(:issue) { create(:issue) }

  let(:document) { create(:document, documentable: issue) }
  let(:customer) { issue.customer }

  let(:parsed_content) do
    %{
      <html>
        <body>
          <h1>Invoice</h1>
          <p>Customer: John</p>
        </body>
      </html>
    }
  end

  let(:faraday_response) { instance_double(Faraday::Response, success?: true, body: parsed_content) }

  let(:parser_api_instance) { instance_double(::Converter::ApiClient) }
  let(:parser_result) { Dry::Monads::Success(faraday_response) }

  describe '#document_email' do
    let(:mail) { described_class.call(issue:, documents: [document], template:).deliver_now }

    let!(:template) do
      create(:template, template_type: :mail, name: :document,
                        subject: "Es gibt ein neues Dokument fuer Ihre Anfrage",
                        body:
        %{
          <html>
            <body>
              <h1>Document email with an attachment</h1>
              <p>Customer: {{customer.name}}</p>
            </body>
          </html>
        })
    end
    before do
      # Clear out any previously collected emails
      allow(::Converter::ApiClient).to receive(:new).and_return(parser_api_instance)
      allow(parser_api_instance).to receive(:parse).and_return(parser_result)
      ActionMailer::Base.deliveries.clear
    end

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t('mailer.customer.document_email.subject'))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([customer.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([customer.account.merchant.email])
    end

    it 'has an attachment' do
      expect(mail.attachments.size).to eq(1)
    end

    it 'has the correct attachment filename' do
      expect(mail.attachments.first.filename).to eq(document.file.blob.filename.to_s)
    end

    it 'has the correct attachment content' do
      expect(mail.attachments.first.body.decoded).to eq(document.file.blob.download)
    end

    it 'sends the email' do
      # Call the document_email method to trigger the email send
      described_class.call(issue:, documents: [document], template:).deliver_now

      # Expect that one email was sent
      expect(ActionMailer::Base.deliveries.count).to eq(1)

      # Expect that the email has the correct subject
      expect(ActionMailer::Base.deliveries.first.subject)
        .to eq(I18n.t('mailer.customer.document_email.subject'))

      # Expect that the email has the correct receiver
      expect(ActionMailer::Base.deliveries.first.to)
        .to eq([customer.email])

      # Expect that the email has an attachment
      expect(ActionMailer::Base.deliveries.first.attachments.count)
        .to eq(1)

      # Expect that the attachment has the correct filename
      expect(ActionMailer::Base.deliveries.first.attachments.first.filename)
        .to eq(document.file.blob.filename.to_s)

      # Expect that the attachment content matches the expected value
      expect(ActionMailer::Base.deliveries.first.attachments.first.body.decoded)
        .to eq(document.file.blob.download)
    end
  end
end
