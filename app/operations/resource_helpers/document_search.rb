module ResourceHelpers
  class DocumentSearch < BaseSearch
    attributes :search_query, :scope, :model, :search_by

    def call
      proccess_search
    end

    private

    def search_method
      "search_by_#{search_by}"
    end

    def proccess_search
      return Success(send(search_method)) if respond_to?(search_method, true)

      Success(scope.none)
    end
  end
end
