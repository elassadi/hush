module Issues
  class PrintRepairReportOperation < BaseOperation
    attributes :issue
    optional_attributes :notify_customer

    def call
      result = print_repair_report_document
      document = result.success
      if result.success?
        Event.broadcast(:issue_repair_report_printed, document_id: document.id, notify_customer:)

        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def print_repair_report_document
      yield validate_statuses

      document = yield ::Templates::ConvertOperation.call(
        template: repair_report_template,
        data: repair_report_template.prepare_data(issue),
        account_id: issue.account_id,
        documentable: issue,
        document_class: RepairReportDocument
      )
      Success(document)
    end

    def repair_report_template
      @repair_report_template ||= if Current.application_settings.repair_report_print_template.present?
                                    Template.by_account.find(Current.application_settings.repair_report_print_template)
                                  else
                                    Template.by_account.find_by!(name: "default-repair-report-template")
                                  end
    end

    def validate_statuses
      unless issue.status == "repairing_successfull" || issue.status == "repairing_unsuccessfull"
        return Failure("#{self.class} can only be run on issues with status repairing_successfull or " \
                       "repairing_unsuccessfull issue: #{issue.id}")
      end

      Success(true)
    end
  end
end
