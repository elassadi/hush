class AddLockDataToIssue < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :lockdata, :json, after: :metadata
  end
end
