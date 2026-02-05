module Issues
  class CreateOperation < BaseOperation
    attributes(*%i[device_id customer_id input_device_failure_categories device_accessories_list
                   device_received  ])
    optional_attributes :assignee_id, :selected_repair_set_id, :possible_repair_sets,
                        :private_comment, :has_insurance_case,
                        :insurance_id, :insurance_number, :merchant_id, :source

    attr_reader :issue

    def call
      result = perform_operation
      issue = result.success
      if result.success?
        Event.broadcast(:issue_created, issue_id: issue.id)
        return Success(issue)
      end
      Failure(result.failure)
    end

    private

    def perform_operation
      yield validate_statuses

      @issue = yield create_issue

      yield create_issue_entries
      yield create_empty_rabatt_issue_entry
      yield create_private_comment if private_comment.present?

      Success(issue)
    end

    def create_issue
      issue = Issue.create(device_id:, customer_id:, input_device_failure_categories:,
                           device_accessories_list:, assignee_id:, device_received:,
                           has_insurance_case:,
                           insurance_id:,
                           insurance_number:,
                           merchant_id:,
                           source: source_or_default)

      return Failure(issue) unless issue.valid?

      Success(issue)
    end

    def source_or_default
      source.presence || "backend"
    end

    def create_issue_entries
      if selected_repair_set_id.present?
        yield add_repair_set.call(issue_id: issue.id, repair_set_id: selected_repair_set_id)
      elsif possible_repair_sets.present?
        possible_repair_sets.each do |repair_set_id|
          yield add_repair_set.call(issue_id: issue.id, repair_set_id:)
        end
      elsif issue_has_device_and_failure_categories?
        yield IssueEntries::AddMatchingRepairSetOperation.call(issue:)
      end
      Success(issue)
    end

    def issue_has_device_and_failure_categories?
      issue.device.present? && issue.input_device_failure_categories.present?
    end

    def create_empty_rabatt_issue_entry
      IssueEntries::AddRabattOperation.call(issue_id: issue.id, price: 0)
    end

    def create_private_comment
      comment_instance = issue.comments.create!(
        body: private_comment,
        owner: issue.owner
      )
      Success(comment_instance)
    end

    def validate_statuses
      Success(true)
    end

    def add_repair_set = IssueEntries::AddRepairSetOperation
  end
end
