module ResourceHelpers
  class RepairSetSearch < BaseSearch
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

    def search_by_set_name
      # search_by_name
      scope.ransack(name_has_every_term: search_query.strip).result(distinct: false)
    end

    def search_by_model_name
      scope.ransack(name_matches: "%#{search_query}%").result(distinct: false)
    end

    def search_by_id
      scope.where(id: search_query)
    end
  end
end
