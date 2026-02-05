class AddTagsToTemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :templates, :metadata, :json
  end
end
