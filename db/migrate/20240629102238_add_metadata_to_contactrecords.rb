class AddMetadataToContactrecords < ActiveRecord::Migration[7.0]
  def change
    add_column :contact_records, :metadata, :json, after: :salutation
    add_column :contact_records, :status, :string, default: :active, after: :id, limit: 63
  end
end
