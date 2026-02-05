module ResourceHelpers
  class CustomerSearch < BaseSearch
    attributes :search_query, :scope, :model, :search_by
    optional_attributes :global

    def call
      Success(send(search_method))
    end

    private

    def search_method
      "search_by_#{search_by}"
    end

    def proccess_search
      send(search_method)
    end

    def search_by_name
      first_name, last_name = search_query.split(/\s+/)
      conditions = if first_name.present? && last_name.present?
                     {
                       m: 'or',
                       g: [
                         { first_name_matches: "%#{first_name}%", last_name_matches: "%#{last_name}%" },
                         { first_name_matches: "%#{last_name}%", last_name_matches: "%#{first_name}%" }
                       ]
                     }
                   else
                     { first_name_matches: "%#{search_query}%", last_name_matches: "%#{search_query}%", m: 'or' }
                   end

      scope.ransack(conditions).result(distinct: false)
    end

    def search_by_company_name
      full_match = scope.ransack(company_name_matches: "%#{search_query}%").result(distinct: false)
      return full_match if full_match.count > 0

      query_parts = search_query.split
      search_conditions = query_parts.map { |part| { company_name_cont: part } }
      scope.ransack(m: 'and', groupings: search_conditions).result(distinct: false)
    end

    def search_by_email
      scope.where("email like ?", "%#{search_query}%")
    end

    def search_by_id
      return scope.none if global

      scope.where(id: search_query)
    end

    def search_by_mobile_number
      scope.where("mobile_number like ?", "%#{search_query}%")
    end

    def search_by_sequence_id
      return scope.none if global

      super
    end
  end
end
