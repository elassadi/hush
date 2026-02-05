class AddCounterToDocument < ActiveRecord::Migration[7.0]
  def change

    add_column :documents, :counter, :integer, default: 0, after: :id
    add_column :documents, :metadata, :json, after: :key
    add_index :documents, %i[ account_id documentable_type key active_record], unique: true, name: :unique_document_key

  end
end
