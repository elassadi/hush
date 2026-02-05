class RemoveDefaultValueFromTemplateTypes < ActiveRecord::Migration[7.0]
  def change
    change_column_default :templates, :template_type, nil
  end
end
