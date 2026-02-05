module Issues
  class IssueWorkflow < BaseWorkflow
    def repairing_completed?
      %i[repairing_successfull repairing_unsuccessfull].include?(current_state.to_sym)
    end

    class << self
      def create(issue)
        new(issue, workflow_name: "issue_default")
      end

      def human_workflow_statuses
        super(Issue.new)
      end
    end
  end
end
