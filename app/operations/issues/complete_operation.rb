module Issues
  class CompleteOperation < BaseOperation
    attributes :issue
    optional_attributes :relase_stock

    def call
      result = complete_issue
      if result.success?
        # Event.broadcast(:issue_invoice_printed, document_id: document.id, notify_customer:)

        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def complete_issue
      # yield apply_workflow_statuses

      # yield release_stocks if relase_stock
      Success(true)
    end

    def apply_workflow_statuses
      return Failure("Issue is not in the correct status") unless issue.can_run_event?(:complete)

      yield issue.run_event!(:complete)
      Success(true)
    end

    def release_stocks
      Success(true)
    end
  end
end
