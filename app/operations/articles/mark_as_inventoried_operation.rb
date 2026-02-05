module Articles
  class MarkAsInventoriedOperation < BaseOperation
    attributes :article

    def call
      result = mark_as_inventoried_article
      article = result.success
      if result.success?
        # Event.broadcast(:article_activated, article_id: article.id) if article.status_active?
        return Success(article)
      end

      Failure(result.failure)
    end

    private

    def mark_as_inventoried_article
      article.inventoried!
      Success(article)
    end
  end
end
