class CreateEventArchiveTables < ActiveRecord::Migration[7.0]
  def change
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
  end
end
