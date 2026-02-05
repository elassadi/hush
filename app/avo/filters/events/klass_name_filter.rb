module Events
  class KlassNameFilter < Avo::Filters::TextFilter
    self.name = "Klass name filter"
    self.button_label = "Filter by klass name"

    def apply(_request, query, value)
      query.where('klass_name LIKE ?', "%#{value}%")
    end
  end
end
