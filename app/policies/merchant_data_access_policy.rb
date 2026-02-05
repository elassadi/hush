class MerchantDataAccessPolicy < BasePolicy
  attributes :user, :model

  def call
    query = model

    return query if user.access_level_global?

    query = query.where(account_id: user.current_account.id) if model.column_names.include?('account_id')

    query = query.where(merchant_id: user.merchant.id) if model.column_names.include?('merchant_id')

    query
  end
end
