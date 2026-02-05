module Issues
  class PreviewDocumentOperation < BaseOperation
    attributes :issue, :document_type

    def call
      result = preview_document
      document = result.success
      return Success(document) if result.success?

      Failure(result.failure)
    end

    private

    def preview_document
      document = yield ::Templates::ConvertOperation.call(
        template:,
        data: template.prepare_data(issue),
        account_id: issue.account_id, documentable: issue,
        document_class: PreviewDocument
      )

      Success(document)
    end

    def template
      case document_type
      when "order"
        order_template
      when "kva"
        kva_template
      when "invoice"
        invoice_template
      when "canceld_invoice"
        canceld_invoice_template
      else
        raise ArgumentError, "Invalid document type"
      end
    end

    def kva_template
      @kva_template ||= if Current.application_settings.kva_print_template.present?
                          Template.by_account.find(Current.application_settings.kva_print_template)
                        else
                          Template.by_account.find_by!(name: "default-kva-template")
                        end
    end

    def order_template
      @order_template ||= if Current.application_settings.order_print_template.present?
                            Template.by_account.find(Current.application_settings.order_print_template)
                          else
                            Template.by_account.find_by!(name: "default-order-template")
                          end
    end

    def repair_report_template
      @repair_report_template ||= if Current.application_settings.repair_report_print_template.present?
                                    Template.by_account.find(Current.application_settings.repair_report_print_template)
                                  else
                                    Template.by_account.find_by!(name: "default-repair-report-template")
                                  end
    end

    def invoice_template
      @invoice_template ||= if Current.application_settings.invoice_print_template.present?
                              Template.by_account.find(Current.application_settings.invoice_print_template)
                            else
                              Template.by_account.find_by!(name: "default-invoice-template")
                            end
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
  end
end
