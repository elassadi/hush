# config/initializers/zeitwerk.rb
Rails.autoloaders.each do |autoloader|
  autoloader.collapse("#{Rails.root}/app/models/stock")
  autoloader.collapse("#{Rails.root}/app/avo/resources/recloud")
  autoloader.collapse("#{Rails.root}/app/models/recloud")
  # autoloader.inflector.inflect(
  #   'gdpr_handler' => 'GDPRHandler'
  # )
 end