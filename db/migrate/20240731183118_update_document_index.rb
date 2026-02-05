class UpdateDocumentIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :documents, name: "index_squence_id_unique"
    add_index :documents, %i[account_id type sequence_id], unique: true, name: "index_squence_id_unique"

  end
end
