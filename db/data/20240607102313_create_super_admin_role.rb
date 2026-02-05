# frozen_string_literal: true

class CreateSuperAdminRole < ActiveRecord::Migration[7.0]
  def up
    PaperTrail.request(enabled: false) do
      r = Role.create!(name: :super_admin, account: Account.recloud, type: :system, protected: true)
      p = "SuperAdmin1234!"
      User.create!(email: "super_admin@hush-haarentfernung.de",
        name: "super_admin@hush-haarentfernung.de", role_id: r.id,
        password: p , password_confirmation: p,
        account: Account.recloud,
        merchant: Account.recloud.merchant, confirmed_at: Time.zone.now,
        access_level: :global,
        agb: true)
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
