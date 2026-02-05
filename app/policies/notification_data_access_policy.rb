class NotificationDataAccessPolicy < BasePolicy
  attributes :user, :model

  def call
    query = model

    query = query.where(account_id: user.current_account.id) unless user.access_level_global?
    return query if user.admin?

    query.where(receiver_id: user.id).or(query.where(sender_id: user.id))
  end
end
