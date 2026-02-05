class AddColumnAffiliateType < ActiveRecord::Migration[7.0]
  def change
    add_column :merchants, :affiliate_type, :string, index: true, after: :uuid

    Merchant.where(master: true).update_all(affiliate_type: "master")
    Merchant.where(master: false).update_all(affiliate_type: "partner")
  end
end
