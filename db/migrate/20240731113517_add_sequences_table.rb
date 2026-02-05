class AddSequencesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :sequences do |t|
      t.bigint "account_id", null: false, index: true
      t.bigint "setting_id", null: false, index: true
      t.string "uuid", limit: 36, null: false
      t.string "sequenceable_type"
      t.date :active_since
      t.bigint :counter_start, default: 0
      t.json :metadata

      t.timestamps
    end

  end
end
