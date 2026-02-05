# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.0]

  def up
    account = Account.create!(
      name: "Recloud",
      uuid: Constants::RECLOUD_ACCOUNT_UUID,
      email: "account@hush-haarentfernung.de",
      account_type: "recloud",
      plan: "unlimited",
      status: :active,
      legal_form: "GmbH"
    )
    Merchant.create!(company_name:"recloud", account_id: account.id, accounting_email:  "account@hush-haarentfernung.de",
      first_name: "Mohamed", last_name: "Elassadi", master: true, email: "admin@hush-haarentfernung.de",
      affiliate_type: :master
    )

    Setting.categories.each do |category, _value|
      Setting.create!(
        metadata: {},
        account: ,
        category:
      )
    end
    # will be imported

    account = Account.create!(
      name: "hush",
      email: "account@hush-haarentfernung.de",
      account_type: "customer",
      plan: "advanced",
      status: :active,
      legal_form: "GmbH"
    )
    Merchant.create!(company_name:"hush", account_id: account.id, accounting_email:  "account@hush-haarentfernung.de",
      first_name: "Hush", last_name: "Haarentfernung", master: true, email: "hush@hush-haarentfernung.de",
      affiliate_type: :master
    )

    Setting.categories.each do |category, _value|
      Setting.create!(
        metadata: {},
        account: ,
        category:
      )
    end


  end


  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
