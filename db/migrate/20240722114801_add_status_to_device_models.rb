class AddStatusToDeviceModels < ActiveRecord::Migration[7.0]
  def change
    add_column :device_models, :status, :string, default: 'active'
  end
end
