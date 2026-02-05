module IssueEntries
  class UpdatePriceOperation < BaseOperation
    attributes :issue_id, :issue_entry_ids, :user_given_set_price

    def call
      result = update_repair_set
      issue_entries = result.success
      if result.success?
        # Event.broadcast(:issue_entry_activated, issue_entry_id: issue_entry.id) if issue_entry.status_active?
        issue_entries.each do |issue_entry|
          Event.broadcast(:issue_entry_updated, issue_entry_id: issue_entry.id)
        end
        return Success(issue_entries)
      end

      Failure(result.failure)
    end

    private

    def update_repair_set
      issue_entries = yield update_repair_set_issue_entries

      Success(issue_entries)
    end

    def update_repair_set_issue_entries
      yield validate_price
      composed_issue_entries.map do |issue_entry|
        issue_entry.update(price: calculated_prices[issue_entry.id])
        return Failure(issue_entry.errors.full_messages) unless issue_entry.valid? && issue_entry.save

        issue_entry
      end

      Success(composed_issue_entries)
    end

    def composed_issue_entries
      @composed_issue_entries ||= if selected_issue_entries.blank?
                                    issue.issue_entries_with_articles
                                  else
                                    build_composed_entries
                                  end
    end

    def build_composed_entries
      entries = []
      cache_repair_set_entries = {}
      RepairSetEntry.joins(:repair_set)
                    .where(id: selected_issue_entries.pluck(:repair_set_entry_id))
                    .distinct
                    .each do |repair_set_entry|
        next if cache_repair_set_entries[repair_set_entry.repair_set_id].present?

        entries << issue.repair_set_entries(repair_set_entry.repair_set_id)
        cache_repair_set_entries[repair_set_entry.repair_set_id] = true
      end

      selected_issue_entries.each do |issue_entry|
        entries << issue_entry if issue_entry.repair_set_entry_id.blank?
      end
      entries.flatten
    end

    def selected_issue_entries
      @selected_issue_entries ||= IssueEntry.by_account.where(id: issue_entry_ids)
    end

    def issue
      @issue ||= Issue.by_account.find(issue_id)
    end

    def repair_set
      @repair_set ||= RepairSet.by_account.find(repair_set_id)
    end

    def validate_price
      return Failure("Price must be greater than 0") if user_given_set_price < 0

      Success(true)
    end

    def calculated_prices
      @calculated_prices ||= begin
        prices = {}

        total_original_price = composed_issue_entries.sum { |entry| entry.qty * entry.price }
        composed_issue_entries.each do |entry|
          original_value = entry.qty * entry.price
          price_distribution = if total_original_price.zero?
                                 1 / composed_issue_entries.size.to_f
                               else
                                 original_value / total_original_price.to_f
                               end
          new_price = user_given_set_price * price_distribution
          prices[entry.id] = (new_price / entry.qty).round(5)
        end
        prices
      end
    end
  end
end
