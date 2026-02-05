class ChangeIndexForDocuments < ActiveRecord::Migration[7.0]
  def change

    remove_index :documents, name: "unique_document_key"
    remove_index :documents, name: "unique_active_record"

    # Add new unique indexes with the type column included
    add_index :documents, ["account_id", "documentable_type", "key", "type", "active_record"],
      name: "unique_document_key", unique: true
    add_index :documents, ["documentable_id", "documentable_type", "key", "type", "active_record"],
      name: "unique_active_record", unique: true
  end
end
