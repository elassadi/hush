# frozen_string_literal: true

class CreateDeviceModelCategories < ActiveRecord::Migration[7.0]
  def up
    I18n.with_locale(:de) do
      Account.status_active.each do |account|
        next if account.recloud?
        I18n.t("model_categories").each do |category|
          DeviceModelCategory.create!(name: category[:name], description: category[:description], account: account)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
