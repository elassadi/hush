module ResourcesAbilities
  class PurchaseOrderAbility < BaseAbility
    attributes :user, :record

    def call
      apply
    end

    private

    def apply
      record.purchase_order_entries.present?
    end
  end
end
