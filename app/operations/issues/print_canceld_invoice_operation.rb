module Issues
  class PrintCanceldInvoiceOperation < BaseOperation
    attributes :issue
    optional_attributes :notify_customer

    def call
      result = print_canceld_invoice_document
      document = result.success
      if result.success?
        Event.broadcast(:issue_canceld_invoice_printed, document_id: document.id, notify_customer:)

        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def print_canceld_invoice_document
      yield validate_statuses
      yield validate_invoiced_at

      document = yield ::Templates::ConvertOperation.call(
        template: canceld_invoice_template,
        data:,
        account_id: issue.account_id,
        documentable: issue,
        document_class: InvoiceDocument
      )

      issue.update!(last_invoice_canceld_at: Time.zone.now)
      Success(document)
    end

    def canceld_invoice_template
      @canceld_invoice_template ||= if Current.application_settings.canceld_invoice_print_template.present?
                                      Template.by_account.find(
                                        Current.application_settings.canceld_invoice_print_template
                                      )
                                    else
                                      Template.by_account.find_by!(name: "default-canceld-invoice-template")
                                    end
    end

    def data
      canceld_invoice_template.prepare_data(issue).merge(
        invoice: {
          created_at: Time.zone.now,
          canceld_sequence_id:
        }
      )
    end

    def canceld_sequence_id
      issue.invoice.sequence_id
    end

    def validate_statuses
      unless issue.status_category_done?
        return Failure("#{self.class} can only be run on issues with status category done issue: #{issue.id}")
      end

      Success(true)
    end

    def validate_invoiced_at
      if issue.last_invoiced_at.nil?
        return Failure("#{self.class} can only be run on issues that beend invoiced before issue: #{issue.id}")
      end

      Success(true)
    end
  end
end
