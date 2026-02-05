class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.bigint :account_id, null: false, index: true
      t.bigint :owner_id, null: false, index: true
      t.string :uuid, limit: 63, null: false, index: {unique: true}
      t.string :status, limit: 63, null: false
      t.string :activityable_type, limit: 63
      t.bigint :activityable_id, null: false, index: true
      t.json   :metadata
      t.timestamps
    end
  end
end

