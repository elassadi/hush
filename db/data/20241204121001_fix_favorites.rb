# frozen_string_literal: true

class FixFavorites < ActiveRecord::Migration[7.0]
  def up

    SupplierSource.connection.execute(<<-SQL.squish)
      UPDATE supplier_sources SET favorite = false WHERE favorite IS NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
