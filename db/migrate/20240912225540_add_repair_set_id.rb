class AddRepairSetId < ActiveRecord::Migration[7.0]
  def change
    add_column :issue_entries, :sort_repair_set_id, :bigint, index: true, after: :repair_set_entry_id

    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      UPDATE issue_entries
      LEFT JOIN repair_set_entries ON issue_entries.repair_set_entry_id = repair_set_entries.id
      SET issue_entries.sort_repair_set_id = repair_set_entries.repair_set_id ;
    SQL

  end
end
