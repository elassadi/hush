class AddRemindedAtToCalendarEntries < ActiveRecord::Migration[7.0]
  def change
    add_column :calendar_entries, :reminded_at, :datetime
  end
end
