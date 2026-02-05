class AddDeviceModelCategoryToDeviceModelTable < ActiveRecord::Migration[7.0]
  def change
    add_column :device_models, :device_model_category_id, :bigint, index: true
  end
end
