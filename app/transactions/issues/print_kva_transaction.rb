module Issues
  class PrintKvaTransaction < BaseTransaction
    attributes :issue_id
    optional_attributes :notify_customer

    def call
      issue = Issue.find(issue_id)
      document = ActiveRecord::Base.transaction do
        yield print_kva_document.call(issue:, notify_customer:)
      end
      Success(document)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for issue #{issue_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def print_kva_document = Issues::PrintKvaOperation
  end
end
