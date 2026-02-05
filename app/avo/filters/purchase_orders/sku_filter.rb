module PurchaseOrders
  class SkuFilter < Avo::Filters::TextFilter
    self.name = I18n.t(:'filters.purchase_orders.sku_filter.name')
    self.button_label = I18n.t(:'filters.purchase_orders.sku_filter.button_label')

    def apply(_request, query, value)
      query.joins(:all_purchase_order_entries)
           .where(purchase_order_entries: {
                    article: Article.where("sku like '%#{value}%'")
                  })
    end
  end
end
