module Customers
  class NameFilter < Avo::Filters::TextFilter
    self.name = "Name filter"
    self.button_label = "Filter by customer name"

    def apply(_request, query, value)
      query.where('first_name LIKE ?', "%#{value}%").or(
        query.where('last_name LIKE ?', "%#{value}%")
      )
    end
  end
end
