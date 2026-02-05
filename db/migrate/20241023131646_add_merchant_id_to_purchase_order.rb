class AddMerchantIdToPurchaseOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :purchase_orders, :merchant_id, :integer, after: :account_id

    Account.all.each do |account|
      PurchaseOrder.where(account_id: account.id).update_all(merchant_id: account.master_merchant.id)
    end

    change_column_null :purchase_orders, :merchant_id, false

  end
end
