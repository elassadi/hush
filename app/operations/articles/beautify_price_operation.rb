module Articles
  class BeautifyPriceOperation < BaseOperation
    attributes :article

    def call
      result = beautify_price_article
      article = result.success
      if result.success?
        # Event.broadcast(:article_activated, article_id: article.id) if article.status_active?
        return Success(article)
      end

      Failure(result.failure)
    end

    private

    def beautify_price_article
      yield validate_statuses

      # article.status_active!
      # article.client.status_active!

      # yield some_other_methods

      Success(article)
    end

    def validate_statuses
      # unless article.status_approved?
      #   return Failure("#{self.class} invalid_status Must be approved article_id: #{article.id} ")
      # end

      Success(true)
    end
  end
end
