class IssueIncrement < ActiveRecord::Migration[7.0]
  def change
    execute "ALTER TABLE issues AUTO_INCREMENT = 100000"
  end
end
