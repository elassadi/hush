namespace :stripe do
  desc "Chatwoot setup"
  # bundle exec rake "apps:create[app_name,admin_email]"
  task :create_products, %i[dummy_var] => :environment do |_task, _args|
    # dummy_var = args[:dummy_var]
    Rails.logger = Logger.new($stdout)

    Product.status_active.each do |product|
      stripe_product = Stripe::Product.search({
                                                query: "metadata['uuid']:'#{product.uuid}'"
                                              })

      next if stripe_product.any?

      begin
        Stripe::Product.create(
          name: product.name,
          id: product.stripe_product_id,
          metadata: { uuid: product.uuid }
        )
      rescue Stripe::InvalidRequestError
        Rails.logger.warn("Product could not be created")
      end
    end
  end

  task create_prices: :environment do
    Rails.logger = Logger.new($stdout)
    next if Rails.env.production?

    ProviderProductVariant.all.each { |p| p.update(stripe_price_id: nil) }
  end
end
