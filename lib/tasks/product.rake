namespace :product do
  desc "Update article groups and articles for account 2"
  task update: :environment do
    Rails.logger = Logger.new($stdout)
    Current.user = User.system_user
    I18n.locale = :de # Use German translations

    # Tax rate (19%)
    TAX_RATE = 19.0

    # Helper lambda to convert brutto price to netto
    # Round to 5 decimal places to match database precision (precision: 12, scale: 5)
    # This ensures that when converted back to brutto, we get the original price
    brutto_to_netto = lambda do |brutto_price|
      (brutto_price.to_f / (1 + TAX_RATE / 100.0)).round(5)
    end

    account_id = 2
    account = Account.find_by(id: account_id)

    unless account
      puts "Account with ID #{account_id} not found."
      next
    end

    puts "Creating article groups and articles for account: #{account.name} (ID: #{account_id})"
    puts "=" * 60

    # Create "Dienstleistungen Frauen" if it doesn't exist
    group_frauen = ArticleGroup.find_or_initialize_by(
      account_id: account_id,
      name: "Dienstleistungen Frauen"
    )

    if group_frauen.new_record?
      if group_frauen.save
        puts "✓ Created article group: 'Dienstleistungen Frauen'"
      else
        puts "✗ Failed to create article group 'Dienstleistungen Frauen': #{group_frauen.errors.full_messages.join(', ')}"
        next
      end
    else
      puts "→ Article group 'Dienstleistungen Frauen' already exists"
    end

    # Create "Dienstleistungen Männer" if it doesn't exist
    group_maenner = ArticleGroup.find_or_initialize_by(
      account_id: account_id,
      name: "Dienstleistungen Männer"
    )

    if group_maenner.new_record?
      if group_maenner.save
        puts "✓ Created article group: 'Dienstleistungen Männer'"
      else
        puts "✗ Failed to create article group 'Dienstleistungen Männer': #{group_maenner.errors.full_messages.join(', ')}"
        next
      end
    else
      puts "→ Article group 'Dienstleistungen Männer' already exists"
    end

    puts "\n" + "=" * 60
    puts "Creating articles for women (SKU starting from 2000)"
    puts "=" * 60

    # Women treatments data (from _wellness_pricing.html.erb - source of truth)
    women_treatments = [
      { key: 'upper_lip', translation_key: 'hush.wellness.appointment.treatments.upper_lip', min: 12, max: 15 },
      { key: 'eyebrow_wax', translation_key: 'hush.wellness.appointment.treatments.eyebrow_wax', min: 15, max: 15 },
      { key: 'eyebrow_wax_and_shape', translation_key: 'hush.wellness.appointment.treatments.eyebrow_wax_and_shape', min: 20, max: 20 },
      { key: 'full_face', translation_key: 'hush.wellness.appointment.treatments.full_face', min: 30, max: 40 },
      { key: 'underarms', translation_key: 'hush.wellness.appointment.treatments.underarms', min: 15, max: 15 },
      { key: 'forearms', translation_key: 'hush.wellness.appointment.treatments.forearms', min: 25, max: 30 },
      { key: 'full_arms', translation_key: 'hush.wellness.appointment.treatments.full_arms', min: 35, max: 35 },
      { key: 'lower_legs', translation_key: 'hush.wellness.appointment.treatments.lower_legs', min: 35, max: 35 },
      { key: 'upper_legs', translation_key: 'hush.wellness.appointment.treatments.upper_legs', min: 35, max: 35 },
      { key: 'full_legs', translation_key: 'hush.wellness.appointment.treatments.full_legs', min: 55, max: 60 },
      { key: 'classic_bikini', translation_key: 'hush.wellness.appointment.treatments.classic_bikini', min: 25, max: 25 },
      { key: 'deep_bikini', translation_key: 'hush.wellness.appointment.treatments.deep_bikini', min: 45, max: 55 },
      { key: 'stomach', translation_key: 'hush.wellness.appointment.treatments.stomach', min: 20, max: 20 },
      { key: 'lower_back', translation_key: 'hush.wellness.appointment.treatments.lower_back', min: 20, max: 20 },
      { key: 'buttocks', translation_key: 'hush.wellness.appointment.treatments.buttocks', min: 20, max: 20 }
    ]

    # Women packages data
    women_packages = [
      { key: 'package_1', translation_key: 'hush.wellness.appointment.treatments.package_1', min: 65, max: 65 },
      { key: 'package_2', translation_key: 'hush.wellness.appointment.treatments.package_2', min: 95, max: 95 },
      { key: 'package_3', translation_key: 'hush.wellness.appointment.treatments.package_3', min: 120, max: 120 },
      { key: 'package_4', translation_key: 'hush.wellness.appointment.treatments.package_4', min: 130, max: 130 }
    ]

    # Create regular treatments
    sku_counter_women = 2000
    women_treatments.each do |treatment|
      name = I18n.t(treatment[:translation_key])
      # Get English translation
      name_en = I18n.with_locale(:en) { I18n.t(treatment[:translation_key]) }
      brutto_price_max = treatment[:max] # Use highest price in range, or simple price if no range
      brutto_price_min = treatment[:min] # Minimum price in range, or simple price if no range
      price = brutto_to_netto.call(brutto_price_max) # Convert brutto to netto
      min_price = brutto_to_netto.call(brutto_price_min) # Convert min brutto to netto
      sku = sku_counter_women.to_s

      article = Article.find_or_initialize_by(
        account_id: account_id,
        sku: sku
      )

      was_new = article.new_record?

      article.assign_attributes(
        name: name,
        name_en: name_en,
        article_group: group_frauen,
        article_type: 'service',
        unit: 'piece',
        tax: 19,
        default_retail_price: price,
        min_preis: min_price,
        default_purchase_price: 0.0,
        status: 'active'
      )

      if article.save
        if was_new
          puts "✓ Created: #{name} (SKU: #{sku}, Price: €#{price})"
        else
          puts "↻ Updated: #{name} (SKU: #{sku}, Price: €#{price})"
        end
      else
        puts "✗ Failed: #{name} - #{article.errors.full_messages.join(', ')}"
      end

      sku_counter_women += 1
    end

    # Create packages with special SKU format
    pkg_counter_women = 2000
    women_packages.each do |package|
      name = I18n.t(package[:translation_key])
      # Get English translation
      name_en = I18n.with_locale(:en) { I18n.t(package[:translation_key]) }
      brutto_price_max = package[:max] # Use highest price in range, or simple price if no range
      brutto_price_min = package[:min] # Minimum price in range, or simple price if no range
      price = brutto_to_netto.call(brutto_price_max) # Convert brutto to netto
      min_price = brutto_to_netto.call(brutto_price_min) # Convert min brutto to netto
      sku = "pkg-#{pkg_counter_women}"

      article = Article.find_or_initialize_by(
        account_id: account_id,
        sku: sku
      )

      was_new = article.new_record?

      article.assign_attributes(
        name: name,
        name_en: name_en,
        article_group: group_frauen,
        article_type: 'service',
        unit: 'piece',
        tax: 19,
        default_retail_price: price,
        min_preis: min_price,
        default_purchase_price: 0.0,
        status: 'active'
      )

      if article.save
        if was_new
          puts "✓ Created: #{name} (SKU: #{sku}, Price: €#{price})"
        else
          puts "↻ Updated: #{name} (SKU: #{sku}, Price: €#{price})"
        end
      else
        puts "✗ Failed: #{name} - #{article.errors.full_messages.join(', ')}"
      end

      pkg_counter_women += 1
    end

    puts "\n" + "=" * 60
    puts "Creating articles for men (SKU starting from 3000)"
    puts "=" * 60

    # Men treatments data (from frontend) - regular treatments
    men_treatments = [
      { key: 'men_nose', translation_key: 'hush.wellness.men_treatments.nose', min: 15, max: 15 },
      { key: 'men_ears', translation_key: 'hush.wellness.men_treatments.ears', min: 15, max: 15 },
      { key: 'men_eyebrows', translation_key: 'hush.wellness.men_treatments.eyebrows', min: 20, max: 20 },
      { key: 'men_face', translation_key: 'hush.wellness.men_treatments.face', min: 40, max: 40 },
      { key: 'men_arms_to_elbow', translation_key: 'hush.wellness.men_treatments.arms_to_elbow', min: 35, max: 35 },
      { key: 'men_full_arms', translation_key: 'hush.wellness.men_treatments.full_arms', min: 50, max: 50 },
      { key: 'men_legs_to_knees', translation_key: 'hush.wellness.men_treatments.legs_to_knees', min: 45, max: 45 },
      { key: 'men_legs_above_knees', translation_key: 'hush.wellness.men_treatments.legs_above_knees', min: 55, max: 55 },
      { key: 'men_full_legs', translation_key: 'hush.wellness.men_treatments.full_legs', min: 70, max: 70 },
      { key: 'men_back', translation_key: 'hush.wellness.men_treatments.back', min: 50, max: 50 },
      { key: 'men_upper_body', translation_key: 'hush.wellness.men_treatments.upper_body', min: 50, max: 50 }
    ]

    # Men packages data
    men_packages = [
      { key: 'men_package_1', translation_key: 'hush.wellness.men_packages.back_upper_body', min: 100, max: 100 },
      { key: 'men_package_2', translation_key: 'hush.wellness.men_packages.arms_legs_full', min: 120, max: 120 },
      { key: 'men_package_3', translation_key: 'hush.wellness.men_packages.complete', min: 160, max: 160 }
    ]

    # Create regular treatments
    sku_counter_men = 3000
    men_treatments.each do |treatment|
      name = I18n.t(treatment[:translation_key])
      brutto_price_max = treatment[:max] # Use highest price in range, or simple price if no range
      brutto_price_min = treatment[:min] # Minimum price in range, or simple price if no range
      price = brutto_to_netto.call(brutto_price_max) # Convert brutto to netto
      min_price = brutto_to_netto.call(brutto_price_min) # Convert min brutto to netto
      sku = sku_counter_men.to_s

      article = Article.find_or_initialize_by(
        account_id: account_id,
        sku: sku
      )

      was_new = article.new_record?

      article.assign_attributes(
        name: name,
        article_group: group_maenner,
        article_type: 'service',
        unit: 'piece',
        tax: 19,
        default_retail_price: price,
        min_preis: min_price,
        default_purchase_price: 0.0,
        status: 'active'
      )

      if article.save
        if was_new
          puts "✓ Created: #{name} (SKU: #{sku}, Price: €#{price})"
        else
          puts "↻ Updated: #{name} (SKU: #{sku}, Price: €#{price})"
        end
      else
        puts "✗ Failed: #{name} - #{article.errors.full_messages.join(', ')}"
      end

      sku_counter_men += 1
    end

    # Create packages with special SKU format
    pkg_counter_men = 3000
    men_packages.each do |package|
      name = I18n.t(package[:translation_key])
      # Get English translation
      name_en = I18n.with_locale(:en) { I18n.t(package[:translation_key]) }
      brutto_price_max = package[:max] # Use highest price in range, or simple price if no range
      brutto_price_min = package[:min] # Minimum price in range, or simple price if no range
      price = brutto_to_netto.call(brutto_price_max) # Convert brutto to netto
      min_price = brutto_to_netto.call(brutto_price_min) # Convert min brutto to netto
      sku = "pkg-#{pkg_counter_men}"

      article = Article.find_or_initialize_by(
        account_id: account_id,
        sku: sku
      )

      was_new = article.new_record?

      article.assign_attributes(
        name: name,
        name_en: name_en,
        article_group: group_maenner,
        article_type: 'service',
        unit: 'piece',
        tax: 19,
        default_retail_price: price,
        min_preis: min_price,
        default_purchase_price: 0.0,
        status: 'active'
      )

      if article.save
        if was_new
          puts "✓ Created: #{name} (SKU: #{sku}, Price: €#{price})"
        else
          puts "↻ Updated: #{name} (SKU: #{sku}, Price: €#{price})"
        end
      else
        puts "✗ Failed: #{name} - #{article.errors.full_messages.join(', ')}"
      end

      pkg_counter_men += 1
    end

    puts "\n" + "=" * 60
    puts "Task completed!"
  end
end
