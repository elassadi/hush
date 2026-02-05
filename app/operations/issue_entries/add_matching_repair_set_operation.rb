module IssueEntries
  class AddMatchingRepairSetOperation < BaseOperation
    attributes :issue

    def call
      result = add_matching_repair_set_issue_entries
      return Success(issue) if result.success?

      Failure(result.failure)
    end

    private

    def add_matching_repair_set_issue_entries
      yield validate_device
      yield create_issue_entries

      Success(true)
    end

    def validate_device
      return Failure("Issue device is blank") if issue.device.blank?

      Success(true)
    end

    def create_issue_entries
      matching_repair_sets.each do |repair_set|
        yield add_repair_set.call(issue_id: issue.id, repair_set_id: repair_set.id)
      end

      Success(issue)
    end

    def matching_repair_sets
      issue.input_device_failure_categories.flat_map do |category_name|
        match_set(category_name:)
      end
    end

    def match_set(category_name:)
      device_model = issue.device.device_model
      device_color = issue.device.device_color

      query = RepairSet.where(
        account: issue.account,
        device_failure_category: DeviceFailureCategory.by_account.where(name: category_name),
        device_model:
      )
      query.where(device_color: [nil, device_color])
    end

    def add_repair_set = IssueEntries::AddRepairSetOperation
  end
end
