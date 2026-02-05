class AddColumnsToEventTable < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :klass_name, :string, index: true
    add_column :events, :prio, :integer, index: true, default: 0
  end
end
