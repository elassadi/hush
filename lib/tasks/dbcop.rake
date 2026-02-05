namespace :dbcop do
  desc "check if articles are consistent"
  task :articles, %i[auto_correct] => :environment do |_task, args|
    auto_correct = args[:auto_correct] || true
    ActiveRecord::Base.logger = nil
    miss_match_counter = 0
    miss_match_reservation_counter = 0

    StockReservation.status_pending.map do |reservation|
      print "."
      if reservation.originator.issue.status_category.to_s == "done"
        reservation.destroy! if auto_correct
        miss_match_reservation_counter += 1
      end
    end
    puts "\nMiss match found in #{miss_match_reservation_counter} reservations"

    Article.all.each do |article|
      print "."
      next unless (article.stock.in_stock_available != article.stock.in_stock -
        article.stock.count_unfulfilled_reservations) ||
                  article.stock.reserved != article.stock.count_unfulfilled_reservations

      miss_match_counter += 1
      article.stock.update_reservation_quantity! if auto_correct
    end
    puts "\nMiss match found in #{miss_match_counter} articles"
  end

  task :supplier, %i[account_id] => :environment do |_task, args|
    account_id = args[:account_id]
    query = Article.all
    query = query.where(account_id:) if account_id.present?
    ActiveRecord::Base.logger = nil

    mismatched_articles = []
    query.stockable.status_active.each do |article|
      print "."
      old_supplier_id = article.supplier_id
      article.update_best_matching_supplier
      new_supplier_id = article.supplier_id
      mismatched_articles << article if new_supplier_id != old_supplier_id
    end

    puts "Found #{mismatched_articles.size} articles that changed supplier"
  end

  desc "Check all models for account reference consistency"
  task :accounts, %i[auto_correct] => :environment do |_task, args|
    auto_correct = ActiveModel::Type::Boolean.new.cast(args[:auto_correct] || false)
    ActiveRecord::Base.logger = nil
    mismatch_counter = 0
    skip_models = %w[Account Activity Article]

    # Get all models in the application
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    models.each do |model|
      next unless model.reflections.values.any? do |reflection|
                    reflection.macro == :belongs_to && reflection.name == :account
                  end
      next if skip_models.include?(model.name)

      puts "\nChecking model: #{model.name}"

      printed = false
      model.find_each do |record|
        print "."

        # Check all associations for account consistency
        model.reflections.each do |association_name, reflection|
          associated_records = []

          if reflection.options[:polymorphic]
            # Handle polymorphic association
            polymorphic_object = record.send(association_name)
            next unless polymorphic_object.respond_to?(:account_id)

            associated_records = [polymorphic_object]
          else
            # Handle regular belongs_to or has_many association
            target_class = reflection.klass
            next unless target_class.column_names.include?("account_id")

            associated_records = if reflection.macro == :belongs_to
                                   [record.send(association_name)].compact
                                 else
                                   record.send(association_name)
                                 end
          end

          Array(associated_records).each do |associated_record|
            next if associated_record.account_id == record.account_id

            unless printed
              puts "Working on #{associated_record.class.name} "
              printed = true
            end

            mismatch_counter += 1

            # Log mismatch
            puts "\nMismatch found in #{model.name} ID: #{record.id}, " \
                 "associated #{associated_record.class.name} ID: #{associated_record.id}"
            next unless auto_correct

            puts "Correcting account_id for #{associated_record.class.name} " \
                 "ID: #{associated_record.id} from #{associated_record.account_id} to #{record.account_id}"
            associated_record.update!(account_id: record.account_id)
          end
        end
      end
    end
    puts "\n\nFound #{mismatch_counter} mismatches across models."
  end
end
