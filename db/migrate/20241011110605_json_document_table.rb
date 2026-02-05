class JsonDocumentTable < ActiveRecord::Migration[7.0]
  def change

    create_table :json_documents do |t|
      t.string :type
      t.references :jsonable, polymorphic: true, null: false
      t.bigint :account_id, null: false
      t.json :metadata
      t.timestamps
    end

    # Optionally, you could add indexes for performance
    add_index :json_documents, :type
    add_index :json_documents, :account_id
  end
end
