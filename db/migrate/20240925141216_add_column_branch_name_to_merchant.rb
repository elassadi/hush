class AddColumnBranchNameToMerchant < ActiveRecord::Migration[7.0]
  def change
    add_column :merchants, :branch_name, :string, after: :company_name
    ActiveRecord::Base.connection.execute("UPDATE merchants SET branch_name = company_name")
  end
end
