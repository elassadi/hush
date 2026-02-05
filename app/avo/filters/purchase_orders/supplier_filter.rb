module PurchaseOrders
  class SupplierFilter < Avo::Filters::MultipleSelectFilter
    self.name = I18n.t(:'filters.purchase_orders.supplier_filter.name')
    # self.button_label = I18n.t(:'filters.purchase_orders.supplier_filter.button_label')

    def apply(_request, query, values)
      supplier_ids = if values.is_a?(Hash)
                       values.select { |_k, v| v }.keys
                     else
                       values
                     end
      return query if supplier_ids.blank?

      query.where(supplier_id: supplier_ids)
    end

    def options
      Supplier.by_account.status_active
              .select(:id, :account_id, :company_name)
              .order(:company_name)
              .pluck(:id, :company_name).to_h
    end
  end
end
