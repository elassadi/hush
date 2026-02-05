module Templates
  class ConvertOperation < BaseOperation
    attributes :template, :data, :account_id, :documentable, :document_class
    attr_reader :document

    def call
      result = convert_template
      return Success(result.success) if result.success?

      Failure(result.failure)
    end

    private

    def convert_template
      @document = init_document
      content = yield convert_content

      yield save_document(content)

      Success(document)
    end

    def convert_content
      # ApiClient return a Faraday::Response

      data[:document] = document.template_attributes

      response = yield Converter::ApiClient.convert(body: template.body, footer:, data:, name: template.name)

      return Failure(response) unless response.success?

      Success(response.body)
    end

    def footer
      account.global_settings.document_footer
    end

    def account
      @account ||= Account.find(account_id)
    end

    def init_document
      document_class.init(status: :active, documentable:, account_id:)
    end

    def save_document(content)
      filename = "#{document.prefix}-#{document.sequence_id}.pdf"

      document.file.attach(io: StringIO.new(content),
                           filename:,
                           content_type: "application/pdf")
      return Success(document) if document.save!

      Failure(document.errors.full_messages)
    end
  end
end
