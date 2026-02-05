module SupplierArticles
  class AddToArticlesTransaction < BaseTransaction
    attributes :supplier_article_id

    def call
      supplier_article = SupplierArticle.find(supplier_article_id)
      ActiveRecord::Base.transaction do
        yield add_to_articles_supplier_article.call(supplier_article:)
      end
      Success(supplier_article)
    rescue Dry::Monads::Do::Halt => e
      ErrorTracking.capture_message(
        "#{self.class.name} for supplier_article #{supplier_article_id} failed with #{e.result.failure}"
      )
      raise
    end

    private

    def add_to_articles_supplier_article = SupplierArticles::AddToArticlesOperation
  end
end
