class AddSequenceId < ActiveRecord::Migration[7.0]
  def change

    unless ActiveRecord::Base.connection.column_exists?(:customers, :sequence_id)
      add_column :customers, :sequence_id, :string, after: :uuid
    end

    unless ActiveRecord::Base.connection.column_exists?(:issues, :sequence_id)
      add_column :issues, :sequence_id, :string, after: :uuid
    end

    unless ActiveRecord::Base.connection.column_exists?(:documents, :sequence_id)
      add_column :documents, :sequence_id, :string, after: :uuid
    end



    ActiveRecord::Base.connection.execute("UPDATE customers SET sequence_id = id")
    ActiveRecord::Base.connection.execute("UPDATE issues SET sequence_id = id")
    ActiveRecord::Base.connection.execute("UPDATE documents SET sequence_id = id")

    # Step 3: Change the sequence_id columns to be null: false
    change_column_null :customers, :sequence_id, false
    change_column_null :issues, :sequence_id, false
    change_column_null :documents, :sequence_id, false

    add_index :customers, %i[account_id sequence_id], unique: true, name: "index_squence_id_unique"
    add_index :issues, %i[account_id sequence_id], unique: true, name: "index_squence_id_unique"
    add_index :documents, %i[account_id documentable_type sequence_id], unique: true, name: "index_squence_id_unique"

  end
end
