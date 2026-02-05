namespace :utils do
  desc "update article price strategy and preserve the margin"
  task :update_article_price_strategy, %i[account_id] => :environment do |_task, args|
    account_id = args[:account_id]

    Article.where(account_id:).each do |article|
      next if article.pricing_strategie != "disabled"
      next unless article.purchase_price > 0

      article.update!(
        pricing_strategie: :percentage,
        margin: ((article.default_retail_price / article.purchase_price) - 1) * 100
      )
    end
  end
  task :correct_issue_uuids, %i[account_id] => :environment do |_task, args|
    account_id = args[:account_id]
    ActiveRecord::Base.connection.execute(
      "UPDATE issues SET uuid = CONCAT('rep_', id) WHERE account_id = #{account_id};"
    )
  end

  # never run this task in production
  # just for console usage
  task :create_public_api_user, %i[account_id] => :environment do |_task, args|
    Current.user = User.system_user

    Account.all.each do |account|
      next if account.recloud?
      next if account.public_user.present?

      Users::CreatePublicApiUserOperation.call(account:)
    end
  end
end
