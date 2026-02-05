module Issues
  module WorkflowEvents
    module AttRepairingSuccessfullEvent
      class CreateRepairReportDocument < BaseWorkflowEvent
        subscribe_to :after_transition_to_repairing_successfull
        attributes :resource_id, :resource_class, :from, :to
        optional_attributes :event_args

        def call
          return Success("Skipped this resource its not an issue") unless issue_ressource?

          yield Issues::PrintRepairReportTransaction.call(issue_id: issue.id,
                                                          notify_customer:)
          Success(true)
        end
      end
    end
  end
end
