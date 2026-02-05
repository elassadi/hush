module IssueEntries
  class CreateOperation < BaseOperation
    attributes(*%i[issue_id article_id repair_set_id article_name category qty price])

    def call
      result = create_issue_entry
      issue_entry = result.success
      if result.success?
        # Event.broadcast(:issue_entry_activated, issue_entry_id: issue_entry.id) if issue_entry.status_active?
        return Success(issue_entry)
      end

      Failure(result.failure)
    end

    private

    def create_issue_entry
      issue_entry = case category.to_sym
                    when :article
                      yield add_article.call(issue_id:, article_id:, qty:, price:)
                    when :repair_set
                      issue_entries = yield add_repair_set.call(issue_id:, repair_set_id:, user_given_set_price: price)
                      issue_entries.first
                    when :text
                      yield add_text.call(issue_id:, article_name:, qty:, price:)
                    when :rabatt
                      yield add_rabatt.call(issue_id:, price:)
                    end
      Success(issue_entry)
    end

    def add_article    = IssueEntries::AddArticleOperation
    def add_repair_set = IssueEntries::AddRepairSetOperation
    def add_text       = IssueEntries::AddTextOperation
    def add_rabatt     = IssueEntries::AddRabattOperation
  end
end
