class AddCreatedAtAndUpdatedAtToTemplates < ActiveRecord::Migration[7.0]
  def change
    # Step 1: Add the columns with null: true
    add_column :templates, :created_at, :datetime, null: true
    add_column :templates, :updated_at, :datetime, null: true

    # Step 2: Update all existing records to the current time
    reversible do |dir|
      dir.up do
        Template.update_all(created_at: Time.zone.now, updated_at: Time.zone.now)
      end
    end

    # Step 3: Change the columns to null: false
    change_column_null :templates, :created_at, false
    change_column_null :templates, :updated_at, false
  end
end
