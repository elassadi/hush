namespace :chatwoot do
  desc "Chatwoot setup"
  # bundle exec rake "apps:create[app_name,admin_email]"
  task :setup, %i[account_id] => :environment do |_task, args|
    account_id = args[:account_id]
    unless account_id
      puts "please provide an account id Qa=1 dev:1 prod:1"
      exit
    end

    Rails.logger = Logger.new($stdout)

    file = Rails.root.join('config/customer_attributes.yaml')
    config = JSON.parse(YAML.load_file(file).to_json)
    custom_attribute_definitions = config["custom_attribute_definitions"]
    labels = config["labels"]

    response = Chatwoot::Accounts::ListLabelsService.call(account_id:)
    raise StandardError, response.failure if response.failure?

    labels_collection = response.success.body["payload"]

    labels.each do |label_definition|
      label_definition["title"].downcase!

      existing_label = labels_collection.detect do |l|
        l["title"].downcase == label_definition["title"]
      end

      result = if existing_label
                 Rails.logger.info("Updating label #{existing_label['title']}")
                 Chatwoot::Accounts::UpdateLabelService.call(
                   label_id: existing_label["id"],
                   account_id:,
                   label_definition:
                 )
               else
                 Rails.logger.info("Creating label #{label_definition['title']}")
                 Chatwoot::Accounts::CreateLabelService.call(
                   account_id:,
                   label_definition:
                 )
               end
      puts label_definition['title']
      raise StandardError, result.failure.body if result.failure?
    end

    response = Chatwoot::Accounts::ListCustomAttributesService.call(account_id:)
    raise StandardError, response.failure if response.failure?

    collection = response.success.body
    custom_attribute_definitions.each do |custom_attribute_definition|
      existing_definition = collection.detect do |custom_attribute|
        custom_attribute["attribute_key"] == custom_attribute_definition["attribute_key"]
      end

      result = if existing_definition
                 Rails.logger.info("Updating Attribute #{existing_definition['attribute_key']}")
                 Chatwoot::Accounts::UpdateCustomAttributesService.call(
                   account_id:,
                   custom_attribute_id: existing_definition["id"],
                   custom_attribute_definition:
                 )
               else
                 Rails.logger.info("Creating attribute #{custom_attribute_definition['attribute_key']}")
                 Chatwoot::Accounts::CreateCustomAttributesService.call(
                   account_id:,
                   custom_attribute_definition:
                 )
               end
      raise StandardError, result.failure.body if result.failure?
    end

    # setup webhook
    # Faraday.post(
    #   "#{ENV['THREE60DIALOG_BASE_URL']}/configs/webhook",
    #   { url: "#{ENV['THREE60DIALOG_WEBHOOK_URL']}/webhooks/whatsapp/#{ENV['THREE60DIALOG_PHONE']}" }.to_json,
    #   { 'D360-API-KEY': ENV["THREE60DIALOG_API_KEY"], 'Content-Type': 'application/json' }
    # )
  end
end
