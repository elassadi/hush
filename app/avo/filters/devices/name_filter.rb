module Devices
  class NameFilter < Avo::Filters::TextFilter
    self.name = "Name filter"
    self.button_label = "Filter by name"

    def apply(_request, query, value)
      query.joins(:device_model).where('device_models.name LIKE ?', "%#{value}%")
    end
  end
end
