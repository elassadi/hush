namespace :accounts do
  desc "Accounts"

  # bundle exec rake "apps:create[app_name,admin_email]"
  task :create, %i[account_name confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    account_name = args[:account_name]
    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [hanswurst, true]"
      puts "Warning all abilities will be deleted "
      next unless confirm
    end

    Current.user = User.system_user
    account = Account.find_by(name: account_name)
    next "Accounts exist" if account.present?

    account_attributes = {
      name: account_name,
      email: "#{account_name}@hush-haarentfernung.de",
      legal_form: "GmbH",
      first_name: "Demo",
      last_name: "Demo",
      password: "Passw0rd",
      account_type: :customer
    }

    result = Accounts::CreateTransaction.call(account_attributes:)

    if result.success?
      Accounts::ActivateTransaction.call(account_id: result.success.id)
      puts "Account created and activated"
      next true
    end

    puts result.failure
  end

  desc "Purge account data and optionally archive it"
  # bundle exec rake "accounts:purge[account_id,archive]"
  task :purge, %i[account_id archive] => :environment do |_task, args|
    account_id = args[:account_id].to_i
    archive = ActiveRecord::Type::Boolean.new.cast(args[:archive])

    if account_id.zero?
      puts "Invalid account_id. Please provide a valid account ID."
      next
    end
    PaperTrail.enabled = false
    Rails.logger = Logger.new($stdout)
    Current.user = User.system_user
    account = Account.status_deleted.find_by(id: account_id)

    unless account
      puts "Account with ID #{account_id} not found or is still active."
      next
    end

    ActiveRecord::Base.connection.tables.each do |table|
      next unless ActiveRecord::Base.connection.column_exists?(table, :account_id)

      begin
        model = table.classify.constantize
      rescue NameError
        puts "Skipping #{table}..."
        next
      end
      records = model.where(account_id:)

      if archive
        puts "Archiving records from #{table}..."
        # records.find_each do |record|
        #   AccountArchive.create!(
        #     table_name: table,
        #     record_id: record.id,
        #     record: record.as_json
        #   )
        # end
      end
      puts "Deleting records from #{table} (#{records.count})..."
      records.delete_all
    end
    account.delete
    puts "Purge completed for account ID #{account_id}. Archive: #{archive}."
  end

  # bundle exec rake "accounts:copy_manufacturers target_account_id]"

  task :copy_manufacturers, %i[target_account_id] => :environment do |_task, args|
    target_account_id = args[:target_account_id].to_i

    hush_account_id = 2
    if target_account_id.zero?
      puts "Invalid target_account_id. Please provide a valid account ID."
      next
    end
    PaperTrail.enabled = false

    Rails.logger = Logger.new($stdout)
    Current.user = User.system_user

    DeviceManufacturer.connection.execute(<<~SQL.squish)
      INSERT INTO device_manufacturers (account_id, name, created_at, updated_at, uuid)
      SELECT #{target_account_id}, name, NOW(), NOW(), CONCAT("dma_", LEFT(UUID(), 8))
      FROM device_manufacturers
      WHERE account_id = #{hush_account_id}
    SQL

    DeviceModel.connection.execute(<<~SQL.squish)
      INSERT INTO device_models (account_id, name, created_at, updated_at, uuid, device_manufacturer_id, device_model_category_id)
      SELECT
        #{target_account_id},
        dm.name,
        dm.created_at,
        dm.updated_at,
        CONCAT("dmo", LEFT(UUID(), 8)),
        (SELECT target_dm.id
         FROM device_manufacturers AS target_dm
         WHERE target_dm.account_id = #{target_account_id}
           AND target_dm.name = source_dm.name
         LIMIT 1),
        (SELECT target_category.id
         FROM device_model_categories AS target_category
         WHERE target_category.account_id = #{target_account_id}
           AND target_category.name = source_category.name
         LIMIT 1)
      FROM device_models AS dm
      INNER JOIN device_manufacturers AS source_dm
        ON dm.device_manufacturer_id = source_dm.id
      INNER JOIN device_model_categories AS source_category
        ON dm.device_model_category_id = source_category.id
      WHERE source_dm.account_id = #{hush_account_id}
    SQL

    DeviceColor.connection.execute(<<~SQL.squish)
      INSERT INTO device_colors (account_id, uuid, device_model_id, name, created_at, updated_at)
      SELECT
        #{target_account_id},
        CONCAT("dco_", LEFT(UUID(), 8)),
        (SELECT target_dm.id
        FROM device_models AS target_dm
        WHERE target_dm.account_id = #{target_account_id}
          AND target_dm.name = source_dm.name
        LIMIT 1),
        dc.name,
        dc.created_at,
        dc.updated_at
      FROM device_colors AS dc
      INNER JOIN device_models AS source_dm
        ON dc.device_model_id = source_dm.id
      WHERE dc.account_id = #{hush_account_id}
    SQL

    Device.connection.execute(<<~SQL.squish)
      INSERT INTO devices (account_id, uuid, device_model_id, device_color_id, imei, created_at, updated_at)
      SELECT
          #{target_account_id},
          CONCAT("dev_", LEFT(UUID(), 8)),
        (SELECT target_model.id
        FROM device_models AS target_model
        WHERE target_model.account_id = #{target_account_id}
          AND target_model.name = source_model.name
        LIMIT 1),
        (SELECT target_color.id
        FROM device_colors AS target_color
        INNER JOIN device_models AS target_model
          ON target_color.device_model_id = target_model.id
        WHERE target_color.account_id = #{target_account_id}
          AND target_color.name = source_color.name
          AND target_model.name = source_model.name
        LIMIT 1),
        d.imei,
        NOW(),
        NOW()
      FROM devices AS d
      INNER JOIN device_models AS source_model
        ON d.device_model_id = source_model.id
      INNER JOIN device_colors AS source_color
        ON d.device_color_id = source_color.id
      WHERE source_model.account_id = #{hush_account_id} AND d.imei IS NOT NULL
    SQL
  end
end
