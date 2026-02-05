class CreateLeads < ActiveRecord::Migration[7.0]
  def change
    create_table :leads do |t|
      t.string :email
      t.string :company_name
      t.string :phone_number
      t.text :message

      t.timestamps
    end
  end
end
