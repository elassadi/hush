module IssueEntries
  class AddArticleOperation < BaseOperation
    attributes :issue_id, :article_id, :qty, :price

    def call
      result = create_article_issue_entry
      issue_entry = result.success
      if result.success?
        Event.broadcast(:issue_entry_created, issue_entry_id: issue_entry.id)
        return Success(issue_entry)
      end
      Failure(result.failure)
    end

    private

    def create_article_issue_entry
      yield validate_statuses

      issue_entry = update_existing_entry || create_new_issue_entry
      return Success(issue_entry) if issue_entry.valid?

      Failure(issue_entry)
    end

    def update_existing_entry
      entry = issue.issue_entries.find_by(article:, price:)
      return unless entry

      entry.update(qty: entry.qty + qty)
      entry
    end

    def create_new_issue_entry
      issue.issue_entries.create(article_name: article.name, article:, qty:, price:, category: :article)
    end

    def issue
      @issue ||= Issue.by_account.find(issue_id)
    end

    def article
      @article ||= Article.by_account.find(article_id)
    end

    def validate_statuses
      Success(true)
    end
  end
end
