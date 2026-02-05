module Issues
  class UpdateOperation < BaseOperation
    attributes(*%i[ issue device_id customer_id input_device_failure_categories device_accessories_list
                    device_received  ])
    optional_attributes :assignee_id, :has_insurance_case, :insurance_id, :insurance_number, :possible_repair_sets
    attr_reader :cached_issue

    def call
      @cached_issue = issue.dup

      result = perform_update_operation
      issue = result.success
      if result.success?
        # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
        return Success(issue)
      end

      Failure(result.failure)
    end

    private

    def perform_update_operation
      yield update_issue
      if need_to_update_repair_sets?
        yield clean_repair_sets
        yield create_issue_entries
      end
      Success(issue)
    end

    def update_issue
      yield validate_statuses

      issue.update(
        device_id:,
        customer_id:,
        input_device_failure_categories:,
        device_accessories_list:,
        assignee_id:,
        has_insurance_case:,
        insurance_id:,
        insurance_number:
      )

      yield update_device_received

      return Failure(issue) unless issue.valid?

      Success(issue)
    end

    def update_device_received
      return Success(true) if device_received == cached_issue.device_received

      issue.update(device_received:)

      Issues::UpdateWorkflowStatusTransaction.call(issue_id: issue.id)

      Success(true)
    end

    def clean_repair_sets
      IssueEntries::CleanRepairSetsOperation.call(issue:)
    end

    def need_to_update_repair_sets?
      return false if issue.device_id.blank?
      return true if possible_repair_sets.present?

      cached_issue.input_device_failure_categories.sort != issue.input_device_failure_categories.sort ||
        cached_issue.device_id != issue.device_id
    end

    def create_issue_entries
      return IssueEntries::AddMatchingRepairSetOperation.call(issue:) if possible_repair_sets.blank?

      possible_repair_sets.each do |repair_set_id|
        yield IssueEntries::AddRepairSetOperation.call(issue_id: issue.id, repair_set_id:)
      end
      Success(issue)
    end

    def validate_statuses
      # unless issue.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved issue_id: #{issue.id} ")
      # end

      Success(true)
    end
  end
end
