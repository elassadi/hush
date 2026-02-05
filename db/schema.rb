# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_12_02_130000) do
  create_table "abilities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "role_id"
    t.json "resources", null: false
    t.json "action_tags", null: false
    t.string "effect", limit: 10, default: "deny", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_abilities_on_account_id"
    t.index ["role_id"], name: "index_abilities_on_role_id"
    t.index ["uuid"], name: "index_abilities_on_uuid", unique: true
  end

  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.string "status", limit: 63, null: false
    t.string "plan", limit: 63, null: false
    t.string "account_type", limit: 63, null: false
    t.string "name", limit: 63, null: false
    t.string "legal_form", limit: 63, null: false
    t.string "email", limit: 63
    t.string "phone", limit: 63
    t.string "bank_name", limit: 63
    t.string "first_name", limit: 63
    t.string "last_name", limit: 63
    t.string "bank_account_owner", limit: 63
    t.string "iban", limit: 63
    t.string "bic", limit: 63
    t.string "tax_number", limit: 63
    t.string "ihk_number", limit: 16
    t.string "vat_id_number", limit: 14
    t.json "metadata"
    t.datetime "disabled_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subdomain"
    t.index ["email"], name: "index_accounts_on_email"
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["uuid"], name: "index_accounts_on_uuid"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "owner_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "status", limit: 63, null: false
    t.string "activityable_type", limit: 63
    t.bigint "activityable_id", null: false
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_activities_on_account_id"
    t.index ["activityable_id"], name: "index_activities_on_activityable_id"
    t.index ["owner_id"], name: "index_activities_on_owner_id"
    t.index ["uuid"], name: "index_activities_on_uuid", unique: true
  end

  create_table "address_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "object", size: :long
    t.datetime "created_at"
    t.index ["account_id"], name: "index_address_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_address_versions_on_item_type_and_item_id"
  end

  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "status", limit: 63, null: false
    t.string "street", limit: 63
    t.string "house_number", limit: 63
    t.string "post_code", limit: 63
    t.string "city", limit: 63
    t.string "country", limit: 3, default: "de", null: false
    t.boolean "primary", default: false, null: false
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "primary_record", type: :boolean, as: "if((`primary` = _utf8mb4'1'),1,NULL)"
    t.index ["addressable_type", "addressable_id", "primary_record"], name: "unique_primary_record", unique: true
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "api_tokens", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "counter", default: 0, null: false
    t.string "status", limit: 63, null: false
    t.string "name"
    t.string "token", limit: 36
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_api_tokens_on_account_id"
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "app_configs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["key"], name: "index_app_configs_on_key", unique: true
  end

  create_table "article_groups", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "name", limit: 63
    t.string "description", limit: 1024
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_article_groups_on_account_id"
    t.index ["uuid"], name: "index_article_groups_on_uuid"
  end

  create_table "articles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "status", limit: 63, default: "active"
    t.string "ean", limit: 63
    t.string "sku", null: false
    t.string "article_type", null: false
    t.string "pricing_strategie", limit: 63, null: false
    t.decimal "margin", precision: 12, scale: 5, default: "0.0"
    t.string "name"
    t.string "name_en"
    t.text "description"
    t.json "metadata"
    t.bigint "tax", default: 19, null: false
    t.string "unit", limit: 10, null: false
    t.decimal "default_retail_price", precision: 12, scale: 5, default: "0.0", null: false
    t.decimal "min_preis", precision: 12, scale: 5
    t.decimal "default_purchase_price", precision: 12, scale: 5, default: "0.0", null: false
    t.bigint "supplier_id"
    t.bigint "article_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "inventoried_at"
    t.integer "inventoried_by_id"
    t.index ["account_id", "ean"], name: "index_on_ean", unique: true
    t.index ["account_id", "sku"], name: "index_on_sku", unique: true
    t.index ["account_id"], name: "index_account_id"
    t.index ["article_group_id"], name: "index_articles_on_article_group_id"
    t.index ["ean"], name: "index_articles_on_ean"
    t.index ["sku"], name: "index_articles_on_sku"
    t.index ["supplier_id"], name: "index_articles_on_supplier_id"
    t.index ["uuid"], name: "index_articles_on_uuid"
  end

  create_table "base_orders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "merchant_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "device_id"
    t.bigint "customer_id"
    t.bigint "status", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.text "meta_information"
    t.datetime "to_be_repaired_at"
    t.boolean "has_insurance_case", default: false
    t.bigint "insurance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "quick_order", default: false
    t.string "workflow_state", default: "draft"
    t.bigint "repair_status", default: 0, null: false
    t.datetime "approval_reminded_at"
    t.bigint "repair_set_id"
    t.bigint "migrated_id"
    t.bigint "tax", default: 19
    t.index ["account_id"], name: "index_base_orders_on_account_id"
    t.index ["customer_id"], name: "index_base_orders_on_customer_id"
    t.index ["device_id"], name: "index_base_orders_on_device_id"
    t.index ["insurance_id"], name: "index_base_orders_on_insurance_id"
    t.index ["uuid"], name: "index_base_orders_on_uuid", unique: true
  end

  create_table "calendar_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "uuid", limit: 63, null: false
    t.bigint "account_id", null: false
    t.bigint "owner_id", null: false
    t.string "status", limit: 63, null: false
    t.string "entry_type", limit: 63, null: false
    t.string "calendarable_type", limit: 63
    t.bigint "calendarable_id", null: false
    t.bigint "user_id"
    t.bigint "customer_id"
    t.bigint "issue_id"
    t.json "metadata"
    t.text "description"
    t.datetime "start_at", null: false
    t.datetime "end_at"
    t.boolean "all_day", default: false
    t.string "location"
    t.string "url"
    t.string "color"
    t.string "text_color"
    t.string "background_color"
    t.string "border_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "merchant_id", null: false
    t.datetime "reminded_at"
    t.index ["account_id"], name: "index_calendar_entries_on_account_id"
    t.index ["calendarable_id"], name: "index_calendar_entries_on_calendarable_id"
    t.index ["customer_id"], name: "index_calendar_entries_on_customer_id"
    t.index ["end_at"], name: "index_calendar_entries_on_end_at"
    t.index ["issue_id"], name: "index_calendar_entries_on_issue_id"
    t.index ["owner_id"], name: "index_calendar_entries_on_owner_id"
    t.index ["start_at"], name: "index_calendar_entries_on_start_at"
    t.index ["user_id"], name: "index_calendar_entries_on_user_id"
    t.index ["uuid"], name: "index_calendar_entries_on_uuid", unique: true
  end

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.integer "owner_id", null: false
    t.string "status", limit: 63, null: false
    t.string "commentable_type", limit: 63
    t.bigint "commentable_id", null: false
    t.bigint "reply_to_id"
    t.string "teaser", null: false
    t.text "body", size: :long
    t.json "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "protected", default: false
    t.string "notify_customer_with", default: "none", null: false
    t.string "message_type", limit: 63
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["owner_id"], name: "index_comments_on_owner_id"
    t.index ["reply_to_id"], name: "index_comments_on_reply_to_id"
    t.index ["uuid"], name: "index_comments_on_uuid", unique: true
  end

  create_table "contact_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "status", limit: 63, default: "active"
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "type", limit: 128
    t.string "last_name", limit: 128
    t.string "first_name", limit: 128
    t.string "company_name", limit: 50
    t.string "street", limit: 128
    t.string "post_code", limit: 5
    t.string "city", limit: 128
    t.string "country", limit: 3, default: "DE"
    t.string "email", limit: 128
    t.string "phone_number", limit: 20
    t.string "mobile_number", limit: 20
    t.string "bank_account_owner", limit: 128
    t.string "web_page", limit: 128
    t.string "bank_name", limit: 128
    t.string "iban", limit: 128
    t.string "bic", limit: 128
    t.string "accounting_email", limit: 128
    t.bigint "tax", default: 19
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ceo_name"
    t.string "tax_number"
    t.string "tax_id"
    t.string "hrb_number"
    t.string "court_in_charge"
    t.string "salutation"
    t.json "metadata"
    t.index ["account_id", "email"], name: "index_contact_records_on_email", unique: true
    t.index ["account_id"], name: "index_contact_records_on_account_id"
    t.index ["accounting_email"], name: "index_contact_records_on_accounting_email"
    t.index ["uuid"], name: "index_contact_records_on_uuid", unique: true
  end

  create_table "contract_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "old_object", size: :long
    t.text "old_object_changes", size: :long
    t.datetime "created_at", precision: nil
    t.json "object"
    t.json "object_changes"
    t.index ["account_id"], name: "index_contract_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_contract_versions_on_item_type_and_item_id"
  end

  create_table "customer_notification_rules", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "setting_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "status", limit: 63, null: false
    t.string "channel", limit: 63, null: false
    t.integer "template_id", null: false
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_customer_notification_rules_on_account_id"
    t.index ["channel"], name: "index_customer_notification_rules_on_channel"
    t.index ["setting_id"], name: "index_customer_notification_rules_on_setting_id"
    t.index ["status"], name: "index_customer_notification_rules_on_status"
    t.index ["template_id"], name: "index_customer_notification_rules_on_template_id"
  end

  create_table "customer_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "old_object", size: :long
    t.datetime "created_at", precision: nil
    t.text "old_object_changes", size: :long
    t.json "object"
    t.json "object_changes"
    t.index ["account_id"], name: "index_customer_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_client_versions_on_item_type_and_item_id"
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "merchant_id", null: false
    t.bigint "owner_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "sequence_id", null: false
    t.string "salutation", limit: 10, null: false
    t.string "first_name", limit: 128
    t.string "last_name", limit: 128
    t.string "company_name", limit: 50
    t.string "street", limit: 128
    t.string "city", limit: 128
    t.string "country", limit: 3, default: "DE"
    t.string "post_code", limit: 5
    t.string "email", limit: 128, null: false
    t.string "iban", limit: 128
    t.string "phone_number", limit: 20
    t.string "mobile_number", limit: 20
    t.bigint "primary_address_id"
    t.bigint "shipping_address_id"
    t.bigint "billing_address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "old_ref"
    t.string "status", limit: 63, null: false
    t.datetime "deleted_at"
    t.virtual "active_record", type: :boolean, as: "if((`status` like _utf8mb4'active'),1,NULL)"
    t.index ["account_id", "email", "active_record"], name: "index_customers_on_active_email", unique: true
    t.index ["account_id", "sequence_id", "active_record"], name: "index_customers_on_active_sequence", unique: true
    t.index ["account_id"], name: "index_customers_on_account_id"
    t.index ["billing_address_id"], name: "index_customers_on_billing_address_id"
    t.index ["merchant_id"], name: "index_customers_on_merchant_id"
    t.index ["owner_id"], name: "index_customers_on_owner_id"
    t.index ["primary_address_id"], name: "index_customers_on_primary_address_id"
    t.index ["shipping_address_id"], name: "index_customers_on_shipping_address_id"
    t.index ["uuid"], name: "index_customers_on_uuid", unique: true
  end

  create_table "data_migrations", primary_key: "version", id: :string, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
  end

  create_table "device_colors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "device_model_id", null: false
    t.string "name", limit: 128
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "device_model_id", "name"], name: "index_on_name"
    t.index ["account_id"], name: "index_device_colors_on_account_id"
    t.index ["device_model_id"], name: "index_device_colors_on_device_model_id"
    t.index ["name"], name: "index_device_colors_on_name"
    t.index ["uuid"], name: "index_device_colors_on_uuid", unique: true
  end

  create_table "device_failure_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "name", limit: 128
    t.text "description"
    t.boolean "protected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_taxonomy_records_on_parent_id"
    t.index ["account_id"], name: "index_device_failure_categories_on_account_id"
    t.index ["uuid"], name: "index_device_failure_categories_on_uuid", unique: true
  end

  create_table "device_manufacturers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "name", limit: 63, null: false
    t.text "description", size: :tiny
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_on_name"
    t.index ["account_id"], name: "index_device_manufacturers_on_account_id"
    t.index ["name"], name: "index_device_manufacturers_on_name"
    t.index ["uuid"], name: "index_device_manufacturers_on_uuid", unique: true
  end

  create_table "device_model_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "status", limit: 63, null: false
    t.string "name", limit: 128
    t.text "description"
    t.boolean "protected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_device_model_categories_on_account_id"
    t.index ["uuid"], name: "index_device_model_categories_on_uuid", unique: true
  end

  create_table "device_models", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "device_manufacturer_id", null: false
    t.bigint "gsm_id"
    t.string "name", limit: 128
    t.text "description", size: :tiny
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "active"
    t.bigint "device_model_category_id"
    t.index ["account_id", "device_manufacturer_id", "name"], name: "index_on_name"
    t.index ["account_id"], name: "index_device_models_on_account_id"
    t.index ["device_manufacturer_id"], name: "index_device_models_on_device_manufacturer_id"
    t.index ["name"], name: "index_device_models_on_name"
    t.index ["uuid"], name: "index_device_models_on_uuid", unique: true
  end

  create_table "devices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "imei"
    t.bigint "device_model_id", null: false
    t.bigint "device_color_id"
    t.string "serial_number"
    t.json "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id", "device_model_id"], name: "index_on_device_model_id"
    t.index ["account_id", "imei"], name: "index_on_imei"
    t.index ["account_id", "serial_number"], name: "index_on_sn"
    t.index ["account_id"], name: "index_devices_on_account_id"
    t.index ["uuid"], name: "index_devices_on_uuid", unique: true
  end

  create_table "documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "counter", default: 0
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "sequence_id", null: false
    t.string "status", limit: 63, null: false
    t.string "key"
    t.json "metadata"
    t.string "type"
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.datetime "activated_at"
    t.datetime "archived_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "active_record", type: :boolean, as: "if((`status` like _utf8mb4'active'),1,NULL)"
    t.index ["account_id", "documentable_type", "key", "type", "active_record"], name: "unique_document_key", unique: true
    t.index ["account_id", "type", "sequence_id"], name: "index_squence_id_unique", unique: true
    t.index ["documentable_id", "documentable_type", "key", "type", "active_record"], name: "unique_active_record", unique: true
    t.index ["documentable_id"], name: "index_documents_on_documentable_id"
    t.index ["documentable_type"], name: "index_documents_on_documentable_type"
    t.index ["key"], name: "index_documents_on_key"
    t.index ["type"], name: "index_documents_on_type"
    t.index ["uuid"], name: "index_documents_on_uuid"
  end

  create_table "event_jobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "status"
    t.string "klass_name"
    t.text "result"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_jobs_on_event_id"
  end

  create_table "event_jobs_archive", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "status"
    t.string "klass_name"
    t.text "result"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_jobs_on_event_id"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "retry_counter", default: 0
    t.string "name"
    t.string "status"
    t.text "result"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "klass_name"
    t.integer "prio", default: 0
  end

  create_table "events_archive", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "retry_counter", default: 0
    t.string "name"
    t.string "status"
    t.text "result"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "klass_name"
    t.integer "prio", default: 0
  end

  create_table "issue_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "repair_set_entry_id"
    t.bigint "sort_repair_set_id"
    t.string "category", null: false
    t.bigint "article_id"
    t.bigint "article_unit"
    t.string "article_name", null: false
    t.bigint "issue_id", null: false
    t.bigint "qty", default: 1, null: false
    t.bigint "tax", default: 19, null: false
    t.decimal "price", precision: 12, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "device_failure_entry_id"
    t.decimal "price_b2b", precision: 12, scale: 5, default: "0.0"
    t.index ["account_id"], name: "index_issue_entries_on_account_id"
    t.index ["article_id"], name: "index_issue_entries_on_article_id"
    t.index ["article_name"], name: "index_issue_entries_on_article_name"
    t.index ["category"], name: "index_issue_entries_on_category"
    t.index ["issue_id"], name: "index_issue_entries_on_issue_id"
    t.index ["repair_set_entry_id"], name: "index_issue_entries_on_repair_set_entry_id"
    t.index ["uuid"], name: "index_issue_entries_on_uuid", unique: true
  end

  create_table "issue_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at"
    t.index ["account_id"], name: "index_issue_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_on_item_type_and_item_id"
  end

  create_table "issues", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "merchant_id", null: false
    t.bigint "owner_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "sequence_id", null: false
    t.bigint "device_id"
    t.bigint "customer_id"
    t.string "status", limit: 63, null: false
    t.string "status_category", limit: 63, null: false
    t.json "metadata"
    t.json "lockdata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "assignee_id"
    t.datetime "assigned_at"
    t.datetime "last_invoiced_at"
    t.datetime "last_invoice_canceled_at"
    t.datetime "last_invoice_canceld_at"
    t.index ["account_id", "sequence_id"], name: "index_squence_id_unique", unique: true
    t.index ["account_id"], name: "index_issues_on_account_id"
    t.index ["customer_id"], name: "index_issues_on_customer_id"
    t.index ["device_id"], name: "index_issues_on_device_id"
    t.index ["merchant_id"], name: "index_issues_on_merchant_id"
    t.index ["owner_id"], name: "index_issues_on_owner_id"
    t.index ["status"], name: "index_issues_on_status"
    t.index ["status_category"], name: "index_issues_on_status_category"
    t.index ["uuid"], name: "index_issues_on_uuid", unique: true
  end

  create_table "json_documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.string "jsonable_type", null: false
    t.bigint "jsonable_id", null: false
    t.bigint "account_id", null: false
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_json_documents_on_account_id"
    t.index ["jsonable_type", "jsonable_id"], name: "index_json_documents_on_jsonable"
    t.index ["type"], name: "index_json_documents_on_type"
  end

  create_table "leads", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.string "company_name"
    t.string "phone_number"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "merchants", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "affiliate_type"
    t.virtual "master_record", type: :boolean, as: "if((`master` = _utf8mb4'1'),1,NULL)"
    t.boolean "master", default: false, null: false
    t.string "first_name", limit: 128, null: false
    t.string "last_name", limit: 128, null: false
    t.string "company_name", limit: 50, null: false
    t.string "branch_name"
    t.string "email", limit: 128, null: false
    t.string "phone_number", limit: 20
    t.string "mobile_number", limit: 20
    t.string "bank_account_owner", limit: 128
    t.string "bank_name", limit: 128
    t.string "iban", limit: 128
    t.string "bic", limit: 128
    t.string "accounting_email", limit: 128
    t.string "tax_number", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "ceo_name"
    t.string "court_in_charge"
    t.string "hrb_number"
    t.string "web_page"
    t.index ["account_id", "accounting_email"], name: "index_merchants_on_accounting_email"
    t.index ["account_id", "email"], name: "index_merchants_on_email", unique: true
    t.index ["account_id", "master_record"], name: "index_merchants_on_account_id_and_master_record", unique: true
    t.index ["account_id"], name: "index_merchants_on_account_id"
    t.index ["uuid"], name: "index_merchants_on_uuid", unique: true
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "status", limit: 63, null: false
    t.string "resource", limit: 63
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.string "title", null: false
    t.json "metadata"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_notifications_on_uuid", unique: true
  end

  create_table "purchase_order_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.integer "article_id", null: false
    t.integer "purchase_order_id", null: false
    t.decimal "price", precision: 12, scale: 5, null: false
    t.integer "originator_id"
    t.string "originator_type"
    t.integer "qty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_purchase_order_entries_on_article_id"
    t.index ["originator_id"], name: "index_purchase_order_entries_on_originator_id"
    t.index ["purchase_order_id"], name: "index_purchase_order_entries_on_purchase_order_id"
  end

  create_table "purchase_orders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "merchant_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "status", limit: 63, null: false
    t.string "status_category", limit: 63, null: false
    t.json "metadata"
    t.integer "supplier_id", null: false
    t.integer "tax", default: 19, null: false
    t.decimal "price", precision: 12, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "linked_to_id"
    t.index ["status"], name: "index_purchase_orders_on_status"
    t.index ["status_category"], name: "index_purchase_orders_on_status_category"
    t.index ["supplier_id"], name: "index_purchase_orders_on_supplier_id"
  end

  create_table "repair_set_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "repair_set_id"
    t.bigint "article_id", null: false
    t.bigint "qty", default: 1
    t.boolean "optional", default: false
    t.decimal "margin_b2b", precision: 12, scale: 5, default: "0.0"
    t.decimal "margin_b2c", precision: 12, scale: 5, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tax", default: 19, null: false
    t.index ["account_id"], name: "index_repair_set_entries_on_account_id"
    t.index ["article_id"], name: "index_repair_set_entries_on_article_id"
    t.index ["repair_set_id"], name: "index_repair_set_entries_on_repair_set_id"
    t.index ["uuid"], name: "index_repair_set_entries_on_uuid", unique: true
  end

  create_table "repair_sets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "name"
    t.text "description"
    t.bigint "device_model_id"
    t.bigint "device_failure_category_id"
    t.bigint "device_color_id"
    t.decimal "retail_price_b2b", precision: 12, scale: 5, default: "0.0"
    t.decimal "retail_price", precision: 12, scale: 5, default: "0.0"
    t.decimal "beautified_brutto_b2c", precision: 12, scale: 5, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "unique_name"
    t.index ["account_id"], name: "index_repair_sets_on_account_id"
    t.index ["device_color_id"], name: "index_repair_sets_on_device_color_id"
    t.index ["device_failure_category_id"], name: "index_repair_sets_on_device_failure_category_id"
    t.index ["device_model_id"], name: "index_repair_sets_on_device_model_id"
    t.index ["uuid"], name: "index_repair_sets_on_uuid", unique: true
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "name"
    t.string "status", limit: 63, null: false
    t.boolean "protected", default: false
    t.string "type", limit: 63, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_unique_on_name"
    t.index ["account_id"], name: "index_roles_on_account_id"
    t.index ["uuid"], name: "index_roles_on_uuid", unique: true
  end

  create_table "sequences", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "setting_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "sequenceable_type"
    t.date "active_since"
    t.bigint "counter_start", default: 0
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sequences_on_account_id"
    t.index ["setting_id"], name: "index_sequences_on_setting_id"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.string "category", limit: 63, null: false
    t.json "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["account_id"], name: "index_settings_on_account_id"
    t.index ["category"], name: "index_settings_on_category"
    t.index ["uuid"], name: "index_settings_on_uuid", unique: true
  end

  create_table "sms_queues", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.bigint "issue_id"
    t.string "status", limit: 63, null: false
    t.integer "credit", default: 1, null: false
    t.string "error"
    t.string "provider", limit: 63, default: "recloud"
    t.text "message"
    t.string "to", limit: 23
    t.datetime "queued_at"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "received_at"
    t.datetime "failed_at"
    t.boolean "incoming_sms", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sms_queues_on_account_id"
    t.index ["issue_id"], name: "index_sms_queues_on_issue_id"
    t.index ["status"], name: "index_sms_queues_on_status"
  end

  create_table "stock_areas", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "name", limit: 63, null: false
    t.text "description"
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_areas_on_name", unique: true
    t.index ["account_id", "stock_location_id"], name: "index_stock_areas_on_stock_location_id"
    t.index ["account_id"], name: "index_stock_areas_on_account_id"
    t.index ["uuid"], name: "index_stock_areas_on_uuid"
  end

  create_table "stock_items", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.bigint "status"
    t.bigint "article_id"
    t.bigint "stock_area_id"
    t.bigint "in_stock", default: 0, null: false
    t.bigint "reserved", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_stock_items_on_account_id"
    t.index ["article_id"], name: "index_stock_items_on_article_id"
    t.index ["stock_area_id"], name: "index_stock_items_on_stock_area_id"
    t.index ["uuid"], name: "index_stock_items_on_uuid"
  end

  create_table "stock_locations", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "name", limit: 63, null: false
    t.text "description"
    t.boolean "primary", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "primary_record", type: :boolean, as: "if((`primary` = _utf8mb4'1'),1,NULL)"
    t.index ["account_id", "name"], name: "index_locations_on_name", unique: true
    t.index ["account_id", "primary_record"], name: "unique_primary_record", unique: true
    t.index ["account_id"], name: "index_account_id"
    t.index ["uuid"], name: "index_stock_locations_on_uuid"
  end

  create_table "stock_movements", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.bigint "owner_id", null: false
    t.bigint "article_id"
    t.bigint "stock_item_id"
    t.string "action", limit: 63, null: false
    t.string "action_type", limit: 63, null: false
    t.bigint "stock_location_id", null: false
    t.bigint "stock_area_id", null: false
    t.bigint "qty"
    t.bigint "originator_id"
    t.string "originator_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_stock_movements_on_account_id"
    t.index ["action"], name: "index_stock_movements_on_action"
    t.index ["action_type"], name: "index_stock_movements_on_action_type"
    t.index ["article_id"], name: "index_stock_movements_on_article_id"
    t.index ["originator_id"], name: "index_stock_movements_on_originator_id"
    t.index ["originator_type"], name: "index_stock_movements_on_originator_type"
    t.index ["owner_id"], name: "index_stock_movements_on_owner_id"
    t.index ["stock_area_id"], name: "index_stock_movements_on_stock_area_id"
    t.index ["stock_item_id"], name: "index_stock_movements_on_stock_item_id"
    t.index ["stock_location_id"], name: "index_stock_movements_on_stock_location_id"
    t.index ["uuid"], name: "index_stock_movements_on_uuid"
  end

  create_table "stock_reservations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "status", limit: 63, null: false
    t.integer "article_id", null: false
    t.integer "prio", default: 0, null: false
    t.integer "originator_id"
    t.string "originator_type", limit: 63
    t.integer "qty", null: false
    t.datetime "reserved_at"
    t.datetime "fulfilled_at"
    t.datetime "fulfill_before"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_stock_reservations_on_account_id"
    t.index ["article_id"], name: "index_stock_reservations_on_article_id"
    t.index ["originator_id"], name: "index_stock_reservations_on_originator_id"
    t.index ["originator_type"], name: "index_stock_reservations_on_originator_type"
    t.index ["status"], name: "index_stock_reservations_on_status"
  end

  create_table "stocks", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.bigint "article_id", null: false
    t.bigint "in_stock", default: 0, null: false
    t.bigint "in_stock_available", default: 0, null: false
    t.bigint "reserved", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_stocks_on_account_id"
    t.index ["uuid"], name: "index_stocks_on_uuid"
  end

  create_table "supplier_articles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "supplier_id", null: false
    t.string "sku", limit: 63, null: false
    t.string "ean", limit: 63
    t.string "article_name"
    t.text "article_description"
    t.bigint "tax", default: 19, null: false
    t.string "unit", limit: 10, default: "Stk.", null: false
    t.decimal "purchase_price", precision: 12, scale: 5, default: "0.0", null: false
    t.string "supplier_article_group", limit: 63
    t.string "stock_status", limit: 63, null: false
    t.integer "int_stock_status", default: 0
    t.bigint "days_to_ship", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "manufacturer_number"
    t.index ["account_id", "supplier_id", "sku", "ean"], name: "unique_supplier_articles_on_ean", unique: true
    t.index ["account_id", "supplier_id", "sku"], name: "unique_supplier_articles_on_sku", unique: true
    t.index ["account_id"], name: "index_supplier_articles_on_account_id"
    t.index ["ean"], name: "index_supplier_articles_on_ean"
    t.index ["sku"], name: "index_on_sku_only"
    t.index ["stock_status"], name: "stock_status"
    t.index ["supplier_id"], name: "index_supplier_articles_on_supplier_id"
    t.index ["uuid"], name: "index_supplier_articles_on_uuid", unique: true
  end

  create_table "supplier_sources", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "supplier_id", null: false
    t.bigint "article_id"
    t.string "sku", null: false
    t.string "ean"
    t.string "article_name", null: false
    t.text "article_description"
    t.bigint "tax", default: 19, null: false
    t.string "unit", limit: 10, default: "Stk.", null: false
    t.decimal "purchase_price", precision: 12, scale: 5, default: "0.0", null: false
    t.string "stock_status", limit: 63, null: false
    t.bigint "days_to_ship", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "manufacturer_number"
    t.boolean "favorite", default: false
    t.index ["account_id", "article_id"], name: "index_supplier_sources_on_article_id"
    t.index ["account_id", "ean"], name: "index_supplier_sources_on_ean"
    t.index ["account_id", "sku"], name: "index_supplier_sources_on_sku"
    t.index ["account_id"], name: "index_supplier_sources_on_account_id"
    t.index ["sku"], name: "index_on_sku_only"
    t.index ["stock_status"], name: "stock_status"
    t.index ["supplier_id"], name: "index_supplier_sources_on_supplier_id"
    t.index ["uuid"], name: "index_supplier_sources_on_uuid", unique: true
  end

  create_table "taxonomy_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "parent_id"
    t.string "type", limit: 128
    t.boolean "protected", default: false
    t.string "name", limit: 128
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_id", "name"], name: "index_taxonomy_records_on_parent_id"
    t.index ["account_id"], name: "index_taxonomy_records_on_account_id"
    t.index ["uuid"], name: "index_taxonomy_records_on_uuid", unique: true
  end

  create_table "templates", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 36, null: false
    t.string "name"
    t.text "body"
    t.string "template_type", limit: 63, null: false
    t.string "subject"
    t.boolean "protected", default: false
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_templates_on_account_id"
    t.index ["name", "account_id"], name: "unique_record", unique: true
    t.index ["name"], name: "index_templates_on_name"
    t.index ["template_type"], name: "index_templates_on_template_type"
    t.index ["uuid"], name: "index_templates_on_uuid"
  end

  create_table "user_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "old_object", size: :long
    t.text "old_object_changes", size: :long
    t.datetime "created_at", precision: nil
    t.json "object"
    t.json "object_changes"
    t.index ["account_id"], name: "index_user_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_user_versions_on_item_type_and_item_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "uuid", limit: 63, null: false
    t.bigint "merchant_id", null: false
    t.bigint "current_account_id", null: false
    t.string "name"
    t.string "role"
    t.string "email", null: false
    t.string "salt"
    t.string "ip", limit: 63
    t.boolean "otp_required_for_login"
    t.bigint "consumed_timestep"
    t.string "otp_secret"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "status", default: "active"
    t.bigint "role_id"
    t.string "access_level", limit: 63, default: "account"
    t.boolean "api_only", default: false
    t.boolean "master", default: false
    t.virtual "master_record", type: :boolean, as: "if((`master` = _utf8mb4'1'),1,NULL)"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "locale", limit: 3, default: "de", null: false
    t.index ["account_id", "master_record"], name: "unique_master_record", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "old_object", size: :long
    t.text "old_object_changes", size: :long
    t.datetime "created_at", precision: nil
    t.json "object"
    t.json "object_changes"
    t.index ["account_id"], name: "index_versions_on_account_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "webhook_request_jobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "webhook_request_id", null: false
    t.string "status"
    t.text "result"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webhook_request_id"], name: "index_webhook_request_jobs_on_webhook_request_id"
  end

  create_table "webhook_requests", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "retry_counter", default: 0
    t.string "status", limit: 63, null: false
    t.string "path"
    t.string "event_uuid", limit: 36
    t.string "event", limit: 63
    t.json "body"
    t.json "headers"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event"], name: "index_webhook_requests_on_event"
    t.index ["event_uuid"], name: "index_webhook_requests_on_event_uuid"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
