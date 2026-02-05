namespace :abilities do
  desc "update Account  abilities for recloud account and sync with all accounts"
  # bundle exec rake "abilities:update" to create recloud roles and abilities and check them
  # bundle exec rake "abilities:update[sync, true]" to sync with all accounts
  task :update_system, %i[confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [sync, true]"
      puts "Warning all customer roles and abilities will be synced "
      next unless confirm
    end

    puts "Updating ... "
    PaperTrail.enabled = false
    Roles::CreateCustomerRolesOperation.call(account: Account.recloud)
    Rake::Task['redis:clean_abillities'].invoke

    PaperTrail.enabled = true
    puts "Done."
  end

  task :update_customer, %i[confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [ true]"
      puts "Warning all customer roles and abilities will be synced "
      next unless confirm
    end

    puts "Updating ... "
    PaperTrail.enabled = false
    # Roles::DeleteCustomerRoleAbilitiesOperation.call(account: Account.recloud)
    Account.status_active.account_type_customer.each do |account|
      puts
      puts "Updating account #{account.name}"
      Roles::CreateCustomerRolesOperation.call(account:)
    end
    Rake::Task['redis:clean_abillities'].invoke

    PaperTrail.enabled = true
    puts "Done."
  end
end
