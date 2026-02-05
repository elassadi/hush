module Issues
  class PrintOrderOperation < BaseOperation
    attributes :issue
    optional_attributes :notify_customer

    def call
      result = print_order_document
      document = result.success
      if result.success?
        Event.broadcast(:issue_order_printed, document_id: document.id, notify_customer:)

        return Success(document)
      end
      Failure(result.failure)
    end

    private

    def print_order_document
      yield apply_workflow_statuses
      yield reset_owner_if_api

      document = yield ::Templates::ConvertOperation.call(
        template: order_template,
        data: order_template.prepare_data(issue),
        account_id: issue.account_id, documentable: issue,
        document_class: OrderDocument
      )

      Success(document)
    end

    def reset_owner_if_api
      return Success(true) unless issue.source_api?

      if issue.source_api? && issue.owner.api?
        issue.owner = Current.user
        issue.save!
      end

      Success(true)
    end

    def order_template
      @order_template ||= if Current.application_settings.order_print_template.present?
                            Template.by_account.find(Current.application_settings.order_print_template)
                          else
                            Template.by_account.find_by!(name: "default-order-template")
                          end
    end

    def apply_workflow_statuses
      return Failure("Issue is not in the correct status") unless issue.can_run_event?(:print_order)

      yield issue.run_event!(:print_order)
      Success(true)
    end
  end
end
