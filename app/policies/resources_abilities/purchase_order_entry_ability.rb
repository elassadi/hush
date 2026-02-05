module ResourcesAbilities
  class PurchaseOrderEntryAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      record.purchase_order.status_category_in_progress? || record.purchase_order.status_category_done?
    end
  end
end
