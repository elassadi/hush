module Articles
  class BeautifyPriceAction < ::ApplicationBaseAction
    self.name = "BeautifyPrice"

    # test
    self.visible = lambda do
      return false unless view == :show

      current_user.may?(:beautify_price, resource.model)
    end

    def handle(**args)
      models = args[:models]
      models.each do |model|
        authorize_and_run(:beautify_price, model) do |article|
          beautify_price(article)
        end
      end
    end

    private

    def beautify_price(article)
      Articles::BeautifyPriceTransaction.call(article_id: article.id)
    end
  end
end
