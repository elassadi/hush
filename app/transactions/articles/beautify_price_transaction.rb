module Articles
  class BeautifyPriceTransaction < BaseTransaction
    attributes :article_id

    def call
      article = Article.find(article_id)
      ActiveRecord::Base.transaction do
        yield beautify_price_article.call(article:)
      end
      Success(article)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for article #{article_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def beautify_price_article = Articles::BeautifyPriceOperation
  end
end
