module SupplierArticles
  class AddToArticlesAction < ::ApplicationBaseAction
    self.name = t(:name)
    self.message = t(:message)
    self.icon = "heroicons/outline/plus-circle"

    # test
    self.visible = lambda do
      current_user.may?(:import, SupplierArticle.new)
    end

    def handle(**args)
      models = args[:models]

      models.each do |model|
        authorize_and_run(:add_to_articles, model) do |supplier_article|
          import(supplier_article)
        end
      end
    end

    private

    def import(supplier_article)
      SupplierArticles::AddToArticlesTransaction.call(supplier_article_id: supplier_article.id)
    end
  end
end
