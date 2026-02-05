require 'csv'

namespace :articles do
  desc "Export all articles with price and actual stock count to CSV"
  # Usage: bundle exec rake "articles:export_csv[account_id,output_file]"
  # Example: bundle exec rake "articles:export_csv[1,articles_export.csv]"
  task :export_csv, %i[account_id output_file] => :environment do |_task, args|
    Rails.logger = Logger.new($stdout)
    Current.user = User.system_user

    account_id = args[:account_id]&.to_i
    output_file = args[:output_file] || "articles_export_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"

    puts "Starting article export..."
    puts "Account ID: #{account_id || 'All accounts'}"
    puts "Output file: #{output_file}"

    # Build query
    query = Article.includes(:stock, :article_group)
    query = query.where(account_id:) if account_id&.positive?

    total_count = query.count
    puts "Found #{total_count} articles to export"

    # Generate CSV
    CSV.open(output_file, 'w') do |csv|
      # CSV headers
      csv << [
        'ID',
        'SKU',
        'EAN',
        'Name',
        'Article Type',
        'Status',
        'Unit',
        'Retail Price',
        'Raw Retail Price',
        'Default Retail Price',
        'Purchase Price',
        'Stock Count',
        'Stock Available',
        'Reserved',
        'Article Group',
        'Supplier',
        'Account ID'
      ]

      # Export articles in batches to handle large datasets
      exported_count = 0
      query.find_each(batch_size: 1000) do |article|
        stock = article.stock
        stock_count = stock&.in_stock || 0
        stock_available = stock&.in_stock_available || 0
        reserved = stock&.reserved || 0

        csv << [
          article.id,
          article.sku,
          article.ean,
          article.name,
          article.article_type,
          article.status,
          article.unit,
          article.retail_price&.round(5),
          article.raw_retail_price&.round(5),
          article.default_retail_price&.round(5),
          article.purchase_price&.round(5),
          stock_count,
          stock_available,
          reserved,
          article.article_group&.name,
          article.supplier&.name,
          article.account_id
        ]

        exported_count += 1
        # Progress indicator
        puts "Exported #{exported_count}/#{total_count} articles..." if exported_count % 100 == 0
      end
    end

    puts "Export completed! File saved to: #{File.expand_path(output_file)}"
    puts "Total articles exported: #{total_count}"
  end
end
