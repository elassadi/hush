module Stocks
  class NameFilter < Avo::Filters::TextFilter
    self.name = "Name filter"
    self.button_label = "Filter by name"

    def apply(_request, query, value)
      query.where(article: Article.by_account.where('name LIKE ?', "%#{value}%"))
    end
  end
end
