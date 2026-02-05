class CreateCalendarEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :calendar_entries do |t|

      t.string :uuid, limit: 63, null: false, index: {unique: true}
      t.bigint :account_id, null: false, index: true
      t.bigint :owner_id, null: false, index: true
      t.string :status, limit: 63, null: false
      t.string :entry_type, limit: 63, null: false
      t.string :calendarable_type, limit: 63
      t.bigint :calendarable_id, null: false, index: true
      t.bigint :user_id, index: true
      t.bigint :customer_id, index: true
      t.bigint :issue_id, index: true
      t.json   :metadata

      t.text :description                # Description of the event
      t.datetime :start_at, null: false, index: true  # Start date and time of the event
      t.datetime :end_at, index: true              # End date and time of the event
      t.boolean :all_day, default: false # Indicates if the event is all day
      t.string :location                 # Location of the event
      t.string :url                      # Optional URL related to the event
      t.string :color                    # Optional color to display the event
      t.string :text_color               # Optional text color for the event
      t.string :background_color         # Optional background color for the event
      t.string :border_color             # Optional border color for the event

      t.timestamps
    end

  end
end
