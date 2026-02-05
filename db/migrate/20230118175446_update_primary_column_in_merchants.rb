class UpdatePrimaryColumnInMerchants < ActiveRecord::Migration[7.0]
  def change
    add_column :merchants, :master_record, :boolean, after: :uuid, as: "if((`master` = '1'),1,NULL)"
    add_index :merchants, %i[account_id master_record], unique: true
  end
end
