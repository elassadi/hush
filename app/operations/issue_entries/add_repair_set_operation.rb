module IssueEntries
  class AddRepairSetOperation < BaseOperation
    attributes :issue_id, :repair_set_id
    optional_attributes :user_given_set_price

    def call
      result = add_repair_set
      issue_entries = result.success
      if result.success?
        # Event.broadcast(:issue_entry_activated, issue_entry_id: issue_entry.id) if issue_entry.status_active?
        issue_entries.each do |issue_entry|
          Event.broadcast(:issue_entry_created, issue_entry_id: issue_entry.id)
        end
        return Success(issue_entries)
      end

      Failure(result.failure)
    end

    private

    def add_repair_set
      issue_entries = yield add_repair_set_issue_entries
      yield merge_duplicate_entries(issue_entries)
      if issue.device.blank?
        device = yield create_device
        issue.update(device_id: device.id)
      end

      issue.update(input_device_failure_categories: (issue.input_device_failure_categories.presence || []) |
        [repair_set.device_failure_category.name])

      Success(issue_entries)
    end

    def merge_duplicate_entries(issue_entries)
      duplicates = []
      issue_entries.each do |issue_entry|
        next unless issue_entry.category == "repair_set"

        duplicate_entry = issue.issue_entries.where(
          category: :repair_set,
          repair_set_entry_id: issue_entry.repair_set_entry_id,
          price: issue_entry.price
        ).where.not(id: issue_entry.id).first

        next unless duplicate_entry

        issue_entry.update(qty: duplicate_entry.qty + issue_entry.qty)
        duplicates << duplicate_entry
      end

      duplicates.each(&:destroy)
      Success(true)
    end

    def add_repair_set_issue_entries
      yield validate_statuses
      issue_entries = repair_set.repair_set_entries.map do |repair_set_entry|
        issue_entry = issue.issue_entries.create(
          category: :repair_set,
          qty: repair_set_entry.qty,
          article_name: repair_set_entry.article.name,
          article: repair_set_entry.article,
          tax: repair_set_entry.tax,
          repair_set_entry_id: repair_set_entry.id,
          sort_repair_set_id: repair_set.id,
          article_id: repair_set_entry.article_id,
          price: price_for(repair_set_entry)
        )
        return Failure(issue_entry.errors.full_messages) unless issue_entry.valid? && issue_entry.save

        issue_entry
      end

      Success(issue_entries)
    end

    def create_device
      Devices::CreateOperation.call(
        device_model_id: repair_set.device_model_id,
        device_color_id:,
        serial_number: "Please add a serial number"
      )
    end

    def device_color_id
      repair_set.device_color_id || repair_set.device_model.device_colors.first.id
    end

    def price_for(repair_set_entry)
      if user_given_set_price && user_given_set_price != repair_set.price
        return allocated_price_for_entry(repair_set_entry)
      end

      price_for_entry_after_beautified_set_price(repair_set_entry)
    end

    def issue
      @issue ||= Issue.by_account.find(issue_id)
    end

    def repair_set
      @repair_set ||= RepairSet.by_account.find(repair_set_id)
    end

    def validate_statuses
      Success(true)
    end

    def price_for_entry_after_beautified_set_price(repair_set_entry)
      candidate = repair_set.repair_set_entries.max_by do |entry|
        entry.price * entry.qty
      end
      return repair_set_entry.price if candidate != repair_set_entry

      margin = repair_set.price - repair_set.raw_retail_price
      margin /= candidate.qty
      candidate.price + margin
    end

    def calculated_prices
      @calculated_prices ||= begin
        prices = {}

        entries = repair_set.repair_set_entries

        total_original_price = entries.sum { |entry| entry.qty * entry.price }

        entries.each do |entry|
          original_value = entry.qty * entry.price
          proportion = original_value / total_original_price.to_f
          new_price = user_given_set_price * proportion

          prices[entry.id] = new_price / entry.qty
        end
        prices
      end
    end

    def allocated_price_for_entry(repair_set_entry)
      calculated_prices[repair_set_entry.id]
    end
  end
end
