namespace :templates do
  desc "update template from local files"
  # bundle exec rake "templates:update" to create recloud roles and templates and check them
  # bundle exec rake "templates:update[sync, true]" to sync with all accounts
  task :update, %i[confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [true]"
      puts "Warning all templates will be overwriten"
      next unless confirm
    end

    puts "Updating Templates ... "

    ::PaperTrail.enabled = false

    Dir[Rails.root.join("config/templates/*.yaml")].each do |f|
      template_data = YAML.load_file(f).with_indifferent_access
      Account.all.each do |account|
        template = Template.find_or_initialize_by(account:, name: template_data[:name])
        template.body = template_data[:body]
        template.template_type = template_data[:type]
        template.tags = template_data[:tags]
        template.protected = template_data[:protected].present? ? true : false
        template.subject = template_data[:subject]
        template.save!
      end
    end

    ::PaperTrail.enabled = true
    puts "Done."
  end

  desc "backup template to local files"
  # bundle exec rake "templates:update" to create recloud roles and templates and check them
  # bundle exec rake "templates:update[sync, true]" to sync with all accounts
  task :backup, %i[confirm] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)

    confirm = args[:confirm]

    if Rails.env.production?
      puts "Confirmation needed [true]"
      puts "Warning all templates will be overwriten"
      next unless confirm
    end

    puts "Updating Templates ... "

    ::PaperTrail.enabled = false

    Template.where(account: Account.recloud).each do |template|
      template_data = {
        name: template.name,
        body: template.body,
        type: template.template_type
      }

      Rails.root.join("config/templates/#{template.name}.yaml").write(template_data.to_yaml)
    end

    ::PaperTrail.enabled = true
    puts "Done."
  end
end
