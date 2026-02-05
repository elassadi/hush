module Issues
  class PrintInvoiceOperation < BaseOperation
    attributes :issue

    def call
      result = print_invoice_document
      document = result.success
      if result.success?
        Event.broadcast(:issue_invoice_printed, document_id: document.id)

        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def print_invoice_document
      yield validate_statuses
      yield validate_invoiced_at

      document = yield ::Templates::ConvertOperation.call(
        template: invoice_template,
        data:,
        account_id: issue.account_id,
        documentable: issue,
        document_class: InvoiceDocument
      )

      issue.update!(last_invoiced_at: Time.zone.now)
      Success(document)
    end

    def invoice_template
      @invoice_template ||= if Current.application_settings.invoice_print_template.present?
                              Template.by_account.find(Current.application_settings.invoice_print_template)
                            else
                              Template.by_account.find_by!(name: "default-invoice-template")
                            end
    end

    def data
      invoice_template.prepare_data(issue).merge(
        invoice: {
          created_at: Time.zone.now
        }
      )
    end

    def validate_statuses
      unless issue.status_category_done?
        return Failure("#{self.class} can only be run on issues with status category done issue: #{issue.id}")
      end

      Success(true)
    end

    def validate_invoiced_at
      if issue.last_invoiced_at.present? &&
         (issue.last_invoice_canceld_at.blank? || issue.last_invoiced_at > issue.last_invoice_canceld_at)
        return Failure("#{self.class} can be run on issues that have not been invoiced before issue: #{issue.id}")
      end

      Success(true)
    end
  end
end
