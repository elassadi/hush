Warden::Manager.after_authentication do |user,auth,opts|
  user.update(current_account_id: user.account_id)
end