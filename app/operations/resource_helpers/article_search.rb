module ResourceHelpers
  class ArticleSearch < BaseSearch
    attributes :search_query, :scope, :model, :search_by

    def call
      proccess_search
    end

    private

    def proccess_search
      return Success(send(search_method)) if respond_to?(search_method, true)

      Success(scope.none)
    end

    def search_by_sku
      scope.ransack(sku_matches: "#{search_query}%").result(distinct: false)
    end
  end
end
