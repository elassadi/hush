class CreateComments < ActiveRecord::Migration[7.0]

  TEXT_BYTES = 1_073_741_823

  def change
    create_table :comments do |t|
      t.bigint :account_id, null: false, index: true
      t.string :uuid, limit: 63, null: false, index: {unique: true}
      t.integer :owner_id, null: false, index: true
      t.string :status, limit: 63, null: false
      t.string :commentable_type, limit: 63
      t.bigint :commentable_id, null: false, index: true
      t.bigint :reply_to_id, index: true
      t.string :teaser, null: false
      t.text   :body, limit: TEXT_BYTES
      t.json   :tags
      t.timestamps
    end
  end
end
