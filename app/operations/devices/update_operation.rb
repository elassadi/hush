module Devices
  class UpdateOperation < BaseOperation
    attributes :device, :device_model_id, :device_color_id
    optional_attributes :imei, :serial_number, :unlock_pattern, :unlock_pin

    attr_reader :cached_device

    def call
      @cached_device = device.dup
      result = perform_update_operation
      device = result.success
      if result.success?
        # Event.broadcast(:issue_activated, issue_id: issue.id) if issue.status_active?
        return Success(device)
      end

      Failure(result.failure)
    end

    private

    def perform_update_operation
      yield update_device
      if issue && device_changed?
        yield clean_repair_sets
        yield create_issue_entries
      end
      Success(device)
    end

    def update_device
      yield validate_statuses
      device.update(
        device_model_id:,
        device_color_id:,
        imei:,
        serial_number:,
        unlock_pattern:,
        unlock_pin:
      )
      return Success(device) if device.valid?

      Failure(device)
    end

    def clean_repair_sets
      IssueEntries::CleanRepairSetsOperation.call(issue:)
    end

    def device_changed?
      cached_device.device_model_id != device.device_model_id ||
        cached_device.device_color_id != device.device_color_id
    end

    def create_issue_entries
      IssueEntries::AddMatchingRepairSetOperation.call(issue:)
    end

    def issue
      @issue ||= Issue.by_account
                      .where(status_category: %i[open in_progress], device_id: device.id)
                      .order(created_at: :desc).first
    end

    def validate_statuses
      # unless issue.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved issue_id: #{issue.id} ")
      # end

      Success(true)
    end
  end
end
