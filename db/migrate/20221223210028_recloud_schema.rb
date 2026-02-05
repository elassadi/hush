class RecloudSchema < ActiveRecord::Migration[7.0]
  def change
    create_table "abilities", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 63, null: false, index: {unique: true}
      t.bigint "role_id"
      t.json "resources", null: false
      t.json "action_tags", null: false
      t.string "effect", limit: 10, default: "deny", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["role_id"], name: "index_abilities_on_role_id"
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

    create_table "address_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "item_type", limit: 191, null: false
      t.bigint "item_id", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.string "whodunnit_type"
      t.text "object", size: :long
      t.datetime "created_at"
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
      t.virtual "primary_record", type: :boolean, as: "if((`primary` = '1'),1,NULL)"
      t.index ["addressable_type", "addressable_id", "primary_record"], name: "unique_primary_record", unique: true
      t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
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
      t.index ["email"], name: "index_accounts_on_email"
      t.index ["status"], name: "index_accounts_on_status"
      t.index ["uuid"], name: "index_accounts_on_uuid"
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
      t.string "ean", limit: 63, null: true
      t.string "sku", null: false
      t.string "article_type", null: false
      t.string "name"
      t.text "description"
      t.bigint "tax", default: 19, null: false
      t.string "unit", limit: 10, null: false
      t.decimal "default_retail_price", precision: 12, scale: 5, null: false, default: "0.0"
      t.decimal "default_purchase_price", precision: 12, scale: 5, null: false, default: "0.0"
      t.bigint "supplier_id"
      t.bigint "article_group_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["account_id", "ean"], name: "index_on_ean", unique: true
      t.index ["account_id", "sku"], name: "index_on_sku", unique: true
      t.index ["account_id"], name: "index_account_id"
      t.index ["article_group_id"], name: "index_articles_on_article_group_id"
      t.index ["ean"], name: "index_articles_on_ean"
      t.index ["sku"], name: "index_articles_on_sku"
      t.index ["supplier_id"], name: "index_articles_on_supplier_id"
      t.index ["uuid"], name: "index_articles_on_uuid"
    end

    create_table "contact_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 63, null: false, index: {unique: true}
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
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.string "ceo_name"
      t.string "tax_number"
      t.string "tax_id"
      t.string "hrb_number"
      t.string "court_in_charge"
      t.string "salutation"
      t.index ["accounting_email"], name: "index_contact_records_on_accounting_email"
      t.index ["account_id", "email"], name: "index_contact_records_on_email", unique: true
    end

    create_table "contract_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
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
      t.index ["item_type", "item_id"], name: "index_contract_versions_on_item_type_and_item_id"
    end

    create_table "data_migrations", primary_key: "version", id: :string, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    end

    create_table "documents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 36, null: false
      t.string "status", limit: 63, null: false
      t.string "key"
      t.string "type"
      t.string "documentable_type"
      t.bigint "documentable_id"
      t.datetime "activated_at"
      t.datetime "archived_at"
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.virtual "active_record", type: :boolean, as: "if((`status` like 'active'),1,NULL)"
      t.index ["documentable_id", "documentable_type", "key", "active_record"], name: "unique_active_record", unique: true
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

    create_table "events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "retry_counter", default: 0
      t.string "name"
      t.string "status"
      t.text "result"
      t.json "data"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "roles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 63, null: false, index: {unique: true}
      t.string "name"
      t.string "status", limit: 63, null: false
      t.boolean "protected", default: false
      t.string "type", limit: 63, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["account_id", "name"], name: "index_unique_on_name"
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

    create_table "stock_locations", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 36, null: false
      t.string "name", limit: 63, null: false
      t.text "description"
      t.boolean "primary", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.virtual "primary_record", type: :boolean, as: "if((`primary` = '1'),1,NULL)"
      t.index ["account_id", "name"], name: "index_locations_on_name", unique: true
      t.index ["account_id", "primary_record"], name: "unique_primary_record", unique: true
      t.index ["account_id"], name: "index_account_id"
      t.index ["uuid"], name: "index_stock_locations_on_uuid"
    end

    create_table "stock_movements", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 36, null: false, index: true
      t.bigint "owner_id", null: false, index: true
      t.bigint "article_id", index: true
      t.bigint "stock_item_id", index: true
      t.string "action", limit: 63, null: false, index: true
      t.string "action_type", limit: 63, null: false, index: true
      t.bigint "stock_location_id", null: false, index: true
      t.bigint "stock_area_id", null: false, index: true
      t.bigint "qty"
      t.bigint "originator_id", index: true
      t.string "originator_type", index: true
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "stock_items", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 36, null: false, index: true
      t.bigint "status"
      t.bigint "article_id", index: true
      t.bigint "stock_area_id", index: true
      t.bigint "in_stock", default: 0, null: false
      t.bigint "reserved", default: 0, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end

    create_table "stocks", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 36, null: false, index: true
      t.bigint "article_id", null: false, indexL: true
      t.bigint "in_stock", default: 0, null: false
      t.bigint "in_stock_available", default: 0, null: false
      t.bigint "reserved", default: 0, null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end


    create_table "templates", charset: "utf8mb4", collation: "utf8mb4_german2_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
      t.string "uuid", limit: 36, null: false, index: true
      t.string "name", index: true
      t.text "body"
      t.string "template_type", default: "print", null: false, limit: 63, index: true
      t.string "subject"
      t.boolean "protected", default: false
      t.index ["name", "account_id"], name: "unique_record", unique: true
    end

    create_table "user_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
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
      t.index ["item_type", "item_id"], name: "index_user_versions_on_item_type_and_item_id"
    end

    create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.string "uuid", limit: 63, null: false
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
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.string "status", default: "active"
      t.bigint "role_id"
      t.string "access_level", limit: 63, default: "account"
      t.boolean "api_only", default: false
      t.boolean "master", default: false
      t.virtual "master_record", type: :boolean, as: "if((`master` = '1'),1,NULL)"
      t.index ["account_id", "master_record"], name: "unique_master_record", unique: true
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end

    create_table "versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.bigint "account_id", null: false, index: true
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
      t.string "payment_uuid", limit: 36
      t.string "event", limit: 63
      t.json "body"
      t.json "headers"
      t.string "type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["event"], name: "index_webhook_requests_on_event"
      t.index ["payment_uuid"], name: "index_webhook_requests_on_payment_uuid"
    end

    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"

  end

  create_table "supplier_sources", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "supplier_id", null: false, index: true
    t.bigint "article_id"
    t.string "sku", null: false
    t.string "ean"
    t.string "article_name", null: false
    t.text "article_description"
    t.bigint "tax", default: 19, null: false
    t.string "unit", limit: 10, default: "Stk.", null: false
    t.decimal "purchase_price", precision: 12, scale: 5, default: "0.0", null: false
    t.bigint "stock_status", default: 0
    t.bigint "days_to_ship", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "manufacturer_number"
    t.boolean "favorite", default: false
    t.index ["account_id", "article_id"], name: "index_supplier_sources_on_article_id"
    t.index ["account_id", "ean"], name: "index_supplier_sources_on_ean"
    t.index ["account_id", "sku"], name: "index_supplier_sources_on_sku"
  end

  create_table "supplier_articles", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "supplier_id", null: false, index: true
    t.string "sku", null: false, limit: 63
    t.string "ean", limit: 63, null: true, index: true
    t.string "article_name"
    t.text "article_description"
    t.bigint "tax", default: 19, null: false
    t.string "unit", limit: 10, default: "Stk.", null: false
    t.decimal "purchase_price", precision: 12, scale: 5, default: "0.0", null: false
    t.string "supplier_article_group", limit: 63
    t.bigint "stock_status", default: 0
    t.bigint "days_to_ship", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image_url"
    t.string "manufacturer_number"
    t.index ["account_id","supplier_id", "sku", "ean"], name: "unique_supplier_articles_on_ean", unique: true
    t.index ["account_id","supplier_id", "sku"], name: "unique_supplier_articles_on_sku", unique: true
  end


  create_table "device_manufacturers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.string "name", limit: 63,null: false, index: true
    t.text "description", limit: 255
    t.timestamps
    t.index ["account_id", "name"], name: "index_on_name"
  end

  create_table "device_models", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "device_manufacturer_id", null: false, index: true
    t.bigint "gsm_id"
    t.string "name", limit: 128, index: true
    t.text "description", limit: 255
    t.timestamps
    t.index ["account_id", "device_manufacturer_id", "name"], name: "index_on_name"
  end

  create_table "device_colors", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "device_model_id", null: false, index: true
    t.string "name", limit: 128, index: true
    t.timestamps
    t.index ["account_id", "device_model_id", "name"], name: "index_on_name"
  end

  create_table "devices", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.string "imei"
    t.bigint "device_model_id", null: false
    t.bigint "device_color_id"
    t.string "sn"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["account_id", "imei"], name: "index_on_imei", unique: true
    t.index ["account_id", "device_model_id"], name: "index_on_device_model_id"
    t.index ["account_id", "sn"], name: "index_on_sn"
  end

  create_table "base_orders", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.bigint "merchant_id", null: false
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "device_id"
    t.bigint "customer_id"
    t.bigint "status", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.text "meta_information"
    t.datetime "to_be_repaired_at"
    t.boolean "has_insurance_case", default: false
    t.bigint "insurance_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.boolean "quick_order", default: false
    t.string "workflow_state", default: "draft"
    t.bigint "repair_status", default: 0, null: false
    t.datetime "approval_reminded_at"
    t.bigint "repair_set_id"
    t.bigint "migrated_id"
    t.bigint "tax", default: 19
    t.index ["customer_id"], name: "index_base_orders_on_customer_id"
    t.index ["device_id"], name: "index_base_orders_on_device_id"
    t.index ["insurance_id"], name: "index_base_orders_on_insurance_id"
  end


  create_table "issues", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.bigint "merchant_id", null: false, index: true
    t.bigint "owner_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "device_id", index: true
    t.bigint "customer_id", index: true
    t.string "status", limit: 63, null: false, index: true
    t.string "status_category", limit: 63, null: false, index: true
    t.json "metadata"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "issue_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.json "object"
    t.json "object_changes"
    t.datetime "created_at", precision: 6
    t.index ["item_type", "item_id"], name: "index_on_item_type_and_item_id"
  end


  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.bigint "merchant_id", null: false
    t.bigint "owner_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
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
    t.index ["billing_address_id"], name: "index_customers_on_billing_address_id"
    t.index ["account_id", "email"], name: "index_customers_on_email", unique: true
    t.index ["primary_address_id"], name: "index_customers_on_primary_address_id"
    t.index ["merchant_id"], name: "index_customers_on_merchant_id"
    t.index ["shipping_address_id"], name: "index_customers_on_shipping_address_id"
  end

  create_table "customer_versions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
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
    t.index ["item_type", "item_id"], name: "index_client_versions_on_item_type_and_item_id"
  end


  create_table "merchants", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.boolean "master", null: false, default: false
    t.string "first_name", limit: 128, null: false
    t.string "last_name", limit: 128, null: false
    t.string "company_name", limit: 50, null: false
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
    t.index ["account_id","accounting_email"], name: "index_merchants_on_accounting_email"
    t.index ["account_id","email"], name: "index_merchants_on_email", unique: true
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.string "category", limit: 63, null: false, index: true
    t.json "metadata"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxonomy_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "parent_id"
    t.string "type", limit: 128
    t.boolean "protected", default: false
    t.string "name", limit: 128
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id","parent_id", "name"], name: "index_taxonomy_records_on_parent_id"
  end



  create_table "device_failure_categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.string "name", limit: 128
    t.text "description"
    t.boolean "protected", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id", "name"], name: "index_taxonomy_records_on_parent_id"
  end



  create_table "repair_sets", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.string "name"
    t.text "description"

    t.bigint "device_model_id", index: true
    t.bigint "device_failure_category_id", index: true
    t.bigint "device_color_id", index: true
    t.decimal "target_price_b2b", precision: 12, scale: 5, default: "0.0"
    t.decimal "target_price_b2c", precision: 12, scale: 5, default: "0.0"
    t.decimal "beautified_brutto_b2c", precision: 12, scale: 5, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false

    t.index ["account_id", "name"], name: "unique_name"
  end


  create_table "repair_set_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}

    t.bigint "repair_set_id", index: true
    t.bigint "article_id", null: false, index: true
    t.bigint "qty", default: 1
    t.boolean "optional", default: false
    t.decimal "margin_b2b", precision: 12, scale: 5, default: "0.0"
    t.decimal "margin_b2c", precision: 12, scale: 5, default: "0.0"

    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  # will rename to issue_entries
  create_table "repair_order_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "account_id", null: false, index: true
    t.string "uuid", limit: 63, null: false, index: {unique: true}
    t.bigint "repair_set_entry_id", index: true
    t.string "category", null: false, index: true
    t.bigint "article_id", index: true
    t.bigint "article_unit"
    t.string "article_name", null: false, index: true
    t.bigint "issue_id", null: false, index: true
    t.bigint "qty", default: 1, null: false
    t.bigint "tax", default: 19, null: false
    t.decimal "price", precision: 12, scale: 5
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "device_failure_entry_id"
    t.decimal "price_b2b", precision: 12, scale: 5, default: "0.0"
  end


end
