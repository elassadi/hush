module Stocks
  class SkuFilter < Avo::Filters::TextFilter
    self.name = "Sku filter"
    self.button_label = "Filter by sku"

    def apply(_request, query, value)
      query.where('sku LIKE ?', "%#{value}%")
    end
  end
end
