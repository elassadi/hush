if Rails.env.development? && false
  begin
  require 'listen'
  listener = Listen.to('config') do |modified, added, removed|
    if modified.include?(Rails.root.join('config', 'abilities.yaml').to_s)
      Rails.logger.info "Configuration file changed. Reloading..."

      ::PaperTrail.request(enabled: false) do
        Roles::DeleteCustomerRoleAbilitiesOperation.call(account: Account.recloud)
        Roles::CreateCustomerRolesOperation.call(account: Account.recloud)
        Roles::SyncCustomerRolesTransaction.call(role_ids: Account.recloud.roles.type_customer.pluck(:id))
      end
    end
  end
  listener.start
  rescue LoadError
    puts "not loading listen"
  end

end