class SharedDataAccessPolicy < BasePolicy
  attributes :user, :model

  def call
    return model unless model.column_names.include?('account_id')
    return model if user.access_level_global?

    model.where(account_id: [user.current_account.id, Account.recloud.id])
  end
end
