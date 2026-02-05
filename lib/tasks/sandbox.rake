# namespace :sandbox do
#   desc "Sandbox setup"
#   # bundle exec rake "apps:create[app_name,admin_email]"
#   task :reset, %i[all] => :environment do |_task, args|
#     #account_id = args[:all] || 1
#     Rails.logger = Logger.new($stdout)
#     if Rails.env.qa? || Rails.env.development?
#       puts "Deleting"
#       ChatbotSession.delete_all
#       puts "ChatbotSession:"
#       Contract.delete_all
#       puts "Contract:"
#       Client.delete_all
#       puts "Client:"
#       puts "Done Deleting"
#     else
#       puts "WARNING WARNING WARNING"
#     end
#   end
# end
