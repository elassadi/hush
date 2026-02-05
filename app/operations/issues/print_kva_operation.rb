module Issues
  class PrintKvaOperation < BaseOperation
    attributes :issue
    optional_attributes :notify_customer

    def call
      result = print_kva_document
      document = result.success
      if result.success?
        Event.broadcast(:issue_kva_printed, document_id: document.id, notify_customer:)
        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def print_kva_document
      yield apply_workflow_statuses
      yield reset_owner_if_api

      document = yield ::Templates::ConvertOperation.call(
        template: kva_template,
        data: kva_template.prepare_data(issue),
        account_id: issue.account_id, documentable: issue,
        document_class: KvaDocument
      )

      Success(document)
    end

    def kva_template
      @kva_template ||= if Current.application_settings.kva_print_template.present?
                          Template.by_account.find(Current.application_settings.kva_print_template)
                        else
                          Template.by_account.find_by!(name: "default-kva-template")
                        end
    end

    def reset_owner_if_api
      return Success(true) unless issue.source_api?

      if issue.source_api? && issue.owner.api?
        issue.owner = Current.user
        issue.save!
      end

      Success(true)
    end

    def apply_workflow_statuses
      unless issue.can_run_event?(:print_kva)
        return Failure(I18n.t(:not_in_the_correct_status, scope: "actions.issues.print_kva_action.errors"))
      end

      yield issue.run_event!(:print_kva)
      Success(true)
    end
  end
end
