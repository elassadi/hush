module ResourceHelpers
  class IssueSearch < BaseSearch
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

    def search_by_id
      scope.where("issues.id LIKE ?", "#{search_query}%")
    end

    def search_by_customer_name
      first_name, last_name = search_query.split(/\s+/)

      scope.joins(:customer).where(
        "customers.first_name LIKE :name1 AND customers.last_name LIKE :name2 OR customers.first_name " \
        "LIKE :name2 AND customers.last_name LIKE :name1", name1: "%#{first_name}%", name2: "%#{last_name}%"
      )
    end

    def search_by_customer_company_name
      scope.joins(:customer).where("customers.company_name LIKE ?", "%#{search_query}%")
    end

    def search_by_customer_email
      scope.joins(:customer).where("customers.email LIKE ?", "%#{search_query}%")
    end

    def search_by_customer_mobile_number
      scope.joins(:customer).where("customers.mobile_number LIKE ?", "%#{search_query}%")
    end
  end
end
