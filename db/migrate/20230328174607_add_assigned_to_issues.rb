class AddAssignedToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :assignee_id, :bigint, index: true
    add_column :issues, :assigned_at, :datetime
  end
end
