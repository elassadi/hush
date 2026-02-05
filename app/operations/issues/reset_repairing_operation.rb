module Issues
  class ResetRepairingOperation < BaseOperation
    attributes :issue, :comment

    def call
      result = reset_repairing
      if result.success?
        # Event.broadcast(:issue_invoice_printed, document_id: document.id, notify_customer:)

        return Success(true)
      end

      Failure(result.failure)
    end

    private

    def reset_repairing
      yield validate_status
      # set old report to be able to be edited or deleted
      # issue.repair_report.update!(protected: false)
      issue.device_repaired = nil
      issue.repair_report_id = nil
      issue.save!

      # comment.update!(protected: true)

      action_name = I18n.t("activerecord.attributes.issue.workflow_events.reset_repairing")
      comment.update!(body: "#{action_name}:<b>#{comment.owner.name}</b><br><br>#{comment.body}")

      Success(true)
    end

    def validate_status
      return Failure("Issue is not in the correct status to run reset") unless issue.can_run_event?(:reset_repairing)

      Success(true)
    end
  end
end
