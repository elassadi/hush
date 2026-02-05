class AppConfigKeyFilter < Avo::Filters::TextFilter
  self.name = "Key filter"
  self.button_label = "Filter by key"

  def apply(_request, query, value)
    query.where('`key` LIKE ?', "%#{value}%")
  end
end
