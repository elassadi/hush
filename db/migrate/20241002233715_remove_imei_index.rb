class RemoveImeiIndex < ActiveRecord::Migration[7.0]
  def change

     remove_index :devices, name: "index_on_imei"

     add_index :devices, [:account_id, :imei], name: "index_on_imei"
  end
end
