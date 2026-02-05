class UserDataAccessPolicy < BasePolicy
  attributes :user, :model

  def call
    query = model

    return query if user.access_level_global?

    query = query.where(account_id: user.current_account.id)

    return query if user.admin?

    query.where.not(name: "public_api")
    # query.where(id: user.id)
  end
end
