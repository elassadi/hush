class CreateDeviceModelCategoriesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :device_model_categories do |t|
      t.bigint   :account_id, null: false, index: true
      t.string   :uuid, limit: 63, null: false, index: {unique: true}
      t.string   :status, limit: 63, null: false
      t.string   :name, limit: 128
      t.text     :description
      t.boolean  :protected, default: false

      t.timestamps
    end
  end
end
