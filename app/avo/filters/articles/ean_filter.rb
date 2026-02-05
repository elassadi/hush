module Articles
  class EanFilter < Avo::Filters::TextFilter
    self.name = "ean filter"
    self.button_label = "Filter by ean"

    def apply(_request, query, value)
      query.where('ean LIKE ?', "%#{value}%")
    end
  end
end
