module IssueCalendarEntries
  class CreateOperation < BaseOperation
    attributes(*%i[entry_type calendarable_id calendarable_type start_at end_at merchant_id])
    optional_attributes(*%i[category event_color confirmed_at notes all_day selected_repair_set_id notify_customer
                            source])
    attr_reader :issue_calendar_entry

    def call
      result = validate_and_create_issue_calendar_entry
      issue_calendar_entry = result.success
      if result.success?
        Event.broadcast(:calendar_entry_created, calendar_entry_id: issue_calendar_entry.id, notify_customer:)
        if issue_calendar_entry.confirmed_at && issue_calendar_entry.entry_type.in?(%w[repair regular])
          Event.broadcast(:calendar_entry_confirmed, calendar_entry_id: issue_calendar_entry.id, notify_customer:)
        end
        return Success(issue_calendar_entry)
      end

      Failure(result.failure)
    end

    private

    def validate_and_create_issue_calendar_entry
      yield validate_statuses
      yield validate_merchant_id
      @issue_calendar_entry = yield create_issue_calendar_entry
      yield create_issue

      Success(issue_calendar_entry)
    end

    def create_issue_calendar_entry
      entry = CalendarEntry.create(
        start_at:,
        end_at:,
        calendarable_id:,
        calendarable_type:,
        entry_type:,
        category:,
        event_color:,
        confirmed_at:,
        notes:,
        all_day:,
        selected_repair_set_id:,
        merchant_id:,
        user_id: entry_type == "user" ? calendarable_id : nil,
        notify_customer:,
        source: source || "backend"
      )
      return Failure(entry) unless entry.valid?

      Success(entry)
    end

    def create_issue
      return Success(true) unless entry_type.to_s.in?(%w[regular repair])
      return Success(true) if issue_calendar_entry.calendarable.is_a?(Issue)
      return Success(true) if selected_repair_set_id.blank? && issue_exists_and_assigned?

      issue = yield Issues::CreateTransaction.call(issue_attributes:)

      issue_calendar_entry.customer = issue.customer
      issue_calendar_entry.calendarable = issue
      issue_calendar_entry.save

      Success(issue)
    end

    def issue_exists_and_assigned?
      issue = issue_calendar_entry.calendarable.issues.where(status_category: %i[open in_progress])
                                  .order(created_at: :desc).first

      return false if issue.blank?

      issue_calendar_entry.customer = issue.customer
      issue_calendar_entry.calendarable = issue
      issue_calendar_entry.save
    end

    def issue_attributes
      {
        customer_id: calendarable_id,
        device_id: nil,
        input_device_failure_categories: [],
        device_accessories_list: nil,
        device_received: false,
        selected_repair_set_id:,
        private_comment:,
        merchant_id:,
        source: source || "backend"
      }
    end

    def private_comment
      return if notes.blank?

      "Kundennotiz: #{notes}"
    end

    def validate_merchant_id
      return Failure("Merchant/Branch not found") if merchant_id.blank?
      return Failure("Merchant/Branch not found") unless Current.account.branches.exists?(id: merchant_id)

      Success(true)
    end

    def validate_statuses
      # unless quote.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved quote_id: #{quote.id} ")
      # end

      Success(true)
    end
  end
end
