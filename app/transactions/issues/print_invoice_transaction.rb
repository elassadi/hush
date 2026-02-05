module Issues
  class PrintInvoiceTransaction < BaseTransaction
    attributes :issue_id

    def call
      issue = Issue.find(issue_id)
      document = ActiveRecord::Base.transaction do
        yield print_invoice_document.call(issue:)
      end
      Success(document)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def print_invoice_document = Issues::PrintInvoiceOperation
  end
end
