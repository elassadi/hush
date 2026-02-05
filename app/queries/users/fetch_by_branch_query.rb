module Users
  class FetchByBranchQuery < BaseQuery
    attributes :branch

    def call
      fetch_by_branch
    end

    private

    def fetch_by_branch
      users = if branch.present?
                query = User.by_account
                MerchantDataAccessPolicy.resolve(user: Current.user, model: query)
              else
                User.none
              end

      Success(users)
    end
  end
end
